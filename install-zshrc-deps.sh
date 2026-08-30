#!/usr/bin/env bash
#
# Install everything .zshrc needs, assuming zsh and Oh My Zsh are already there.
#
#   ./install-zshrc-deps.sh                 install required + optional
#   ./install-zshrc-deps.sh --check         report what is missing, install nothing
#   ./install-zshrc-deps.sh --skip-optional install only what .zshrc errors without
#
# Required (.zshrc emits errors/warnings on every startup without these):
#   zsh-vi-mode, zsh-syntax-highlighting, zsh-autosuggestions  (custom OMZ plugins)
#   fzf >= 0.48  (`source <(fzf --zsh)` is unconditional)
#   fd           (FZF_DEFAULT_COMMAND / FZF_CTRL_T_COMMAND / FZF_ALT_C_COMMAND)
#   zoxide       (the OMZ zoxide plugin prints a warning when it is absent)
#
# Optional (.zshrc guards these; without them the feature is just off):
#   starship, atuin, mise
#
# On macOS with Homebrew the tools come from brew; otherwise from upstream
# release binaries into ~/.local/bin (~/.atuin/bin for atuin, matching .zshrc).

set -euo pipefail

CHECK=0
SKIP_OPTIONAL=0
for arg in "$@"; do
  case "$arg" in
    --check) CHECK=1 ;;
    --skip-optional) SKIP_OPTIONAL=1 ;;
    -h|--help) sed -n '2,25p' "$0" | sed 's/^#\{1,2\} \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

BIN_DIR="$HOME/.local/bin"
ATUIN_DIR="$HOME/.atuin/bin"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
FZF_MIN_VERSION=0.48.0

MISSING=()
INSTALLED=()

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[0;32mok\033[0m    %s\n' "$*"; }
skip() { printf '  \033[0;33mtodo\033[0m  %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Where a tool would be found by the shell .zshrc sets up: it prepends
# ~/.local/bin (and ~/.atuin/bin), which may not be on the PATH of this script.
tool_path() {
  if [ -x "$BIN_DIR/$1" ]; then printf '%s\n' "$BIN_DIR/$1"
  elif [ -x "$ATUIN_DIR/$1" ]; then printf '%s\n' "$ATUIN_DIR/$1"
  elif have "$1"; then command -v "$1"
  fi
}

# True when $1 is a version at least as new as $2.
version_at_least() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# ---------------------------------------------------------------- preflight --

case "$(uname -s)" in
  Linux)  OS=linux ;;
  Darwin) OS=darwin ;;
  *) die "unsupported OS: $(uname -s)" ;;
esac

case "$(uname -m)" in
  x86_64|amd64)  ARCH=x86_64 ;;
  aarch64|arm64) ARCH=aarch64 ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

log "Preflight"
have zsh || die "zsh is not installed"
[ -r "$ZSH_DIR/oh-my-zsh.sh" ] || die "Oh My Zsh not found at $ZSH_DIR (set \$ZSH if it lives elsewhere)"
for tool in git curl tar; do
  have "$tool" || die "$tool is required to bootstrap the rest"
done
ok "zsh $(zsh --version | awk '{print $2}'), Oh My Zsh at $ZSH_DIR, $OS/$ARCH"

if [ ! -f "$HOME/.zshrc" ]; then
  warn "$HOME/.zshrc does not exist yet — copy it there before starting a new shell"
elif ! grep -q 'oh-my-zsh.sh' "$HOME/.zshrc"; then
  warn "$HOME/.zshrc does not look like the dotfiles one; installing its dependencies anyway"
fi

USE_BREW=0
if [ "$OS" = darwin ] && have brew; then
  USE_BREW=1
  ok "Homebrew found — tools will be installed with brew"
fi

[ "$CHECK" -eq 1 ] || mkdir -p "$BIN_DIR"

# ------------------------------------------------------------- install helpers --

github_latest_tag() {
  curl -fsSL --retry 3 "https://api.github.com/repos/$1/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1
}

# install_from_tarball <url> <binary-name> <dest-dir>
# Unpacks anywhere in the archive and installs the named binary.
install_from_tarball() {
  local url=$1 bin=$2 dest=$3 tmp found
  tmp=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN
  curl -fsSL --retry 3 "$url" | tar -xzf - -C "$tmp"
  found=$(find "$tmp" -type f -name "$bin" -print -quit)
  [ -n "$found" ] || die "no '$bin' binary inside $url"
  mkdir -p "$dest"
  install -m 0755 "$found" "$dest/$bin"
}

# need <name> <present?> <description>; returns 0 when the caller should install
need() {
  local name=$1 present=$2 desc=$3
  if [ "$present" -eq 0 ]; then
    ok "$name — $desc"
    return 1
  fi
  MISSING+=("$name")
  if [ "$CHECK" -eq 1 ]; then
    skip "$name — $desc"
    return 1
  fi
  log "Installing $name"
  return 0
}

brew_install() { brew list --formula "$1" >/dev/null 2>&1 || brew install "$1"; }

# ------------------------------------------------------------- OMZ plugins --

log "Oh My Zsh custom plugins"
install_plugin() {
  local name=$1 url=$2 dir="$CUSTOM_DIR/plugins/$1"
  local present=1
  [ -d "$dir" ] && present=0
  need "$name" "$present" "$dir" || return 0
  git clone --depth=1 "$url" "$dir"
  INSTALLED+=("$name")
}

install_plugin zsh-vi-mode            https://github.com/jeffreytse/zsh-vi-mode.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions.git

# ------------------------------------------------------------- required tools --

log "Required tools"

# fzf: `source <(fzf --zsh)` runs unconditionally and needs >= 0.48.
fzf_present=1
fzf_found=$(tool_path fzf)
if [ -n "$fzf_found" ]; then
  fzf_version=$("$fzf_found" --version | awk '{print $1}')
  if version_at_least "$fzf_version" "$FZF_MIN_VERSION"; then
    fzf_present=0
  else
    warn "fzf $fzf_version at $fzf_found is too old for 'fzf --zsh' (need >= $FZF_MIN_VERSION); installing a newer one into $BIN_DIR"
    fzf_found=""
  fi
fi
if need fzf "$fzf_present" "${fzf_found:-$BIN_DIR/fzf}"; then
  if [ "$USE_BREW" -eq 1 ]; then
    brew_install fzf
  else
    tag=$(github_latest_tag junegunn/fzf)          # e.g. v0.74.3
    case "$ARCH" in x86_64) a=amd64 ;; aarch64) a=arm64 ;; esac
    install_from_tarball \
      "https://github.com/junegunn/fzf/releases/download/${tag}/fzf-${tag#v}-${OS}_${a}.tar.gz" \
      fzf "$BIN_DIR"
  fi
  INSTALLED+=(fzf)
fi

fd_present=1; fd_found=$(tool_path fd); [ -n "$fd_found" ] && fd_present=0
if need fd "$fd_present" "${fd_found:-$BIN_DIR/fd}"; then
  if [ "$USE_BREW" -eq 1 ]; then
    brew_install fd
  else
    tag=$(github_latest_tag sharkdp/fd)            # e.g. v10.5.0
    case "$OS" in
      linux)  triple="${ARCH}-unknown-linux-musl" ;;
      darwin) triple="${ARCH}-apple-darwin" ;;
    esac
    install_from_tarball \
      "https://github.com/sharkdp/fd/releases/download/${tag}/fd-${tag}-${triple}.tar.gz" \
      fd "$BIN_DIR"
  fi
  INSTALLED+=(fd)
fi

zoxide_present=1; zoxide_found=$(tool_path zoxide); [ -n "$zoxide_found" ] && zoxide_present=0
if need zoxide "$zoxide_present" "${zoxide_found:-$BIN_DIR/zoxide}"; then
  if [ "$USE_BREW" -eq 1 ]; then
    brew_install zoxide
  else
    tag=$(github_latest_tag ajeetdsouza/zoxide)    # e.g. v0.10.0
    case "$OS" in
      linux)  triple="${ARCH}-unknown-linux-musl" ;;
      darwin) triple="${ARCH}-apple-darwin" ;;
    esac
    install_from_tarball \
      "https://github.com/ajeetdsouza/zoxide/releases/download/${tag}/zoxide-${tag#v}-${triple}.tar.gz" \
      zoxide "$BIN_DIR"
  fi
  INSTALLED+=(zoxide)
fi

# ------------------------------------------------------------- optional tools --

if [ "$SKIP_OPTIONAL" -eq 1 ]; then
  log "Optional tools (skipped: --skip-optional)"
else
  log "Optional tools"

  starship_present=1; starship_found=$(tool_path starship); [ -n "$starship_found" ] && starship_present=0
  if need starship "$starship_present" "${starship_found:-$BIN_DIR/starship}"; then
    if [ "$USE_BREW" -eq 1 ]; then
      brew_install starship
    else
      curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$BIN_DIR"
    fi
    INSTALLED+=(starship)
  fi

  # .zshrc puts ~/.atuin/bin on PATH itself, so install there when not using brew.
  atuin_present=1; atuin_found=$(tool_path atuin); [ -n "$atuin_found" ] && atuin_present=0
  if need atuin "$atuin_present" "${atuin_found:-$ATUIN_DIR/atuin}"; then
    if [ "$USE_BREW" -eq 1 ]; then
      brew_install atuin
    else
      tag=$(github_latest_tag atuinsh/atuin)       # e.g. v18.20.1
      case "$OS" in
        linux)  triple="${ARCH}-unknown-linux-musl" ;;
        darwin) triple="${ARCH}-apple-darwin" ;;
      esac
      install_from_tarball \
        "https://github.com/atuinsh/atuin/releases/download/${tag}/atuin-${triple}.tar.gz" \
        atuin "$ATUIN_DIR"
    fi
    INSTALLED+=(atuin)
  fi

  # .zshrc activates mise only from ~/.local/bin/mise, so that exact path matters.
  mise_present=1; [ -x "$BIN_DIR/mise" ] && mise_present=0
  if need mise "$mise_present" "$BIN_DIR/mise"; then
    if [ "$USE_BREW" -eq 1 ] && [ "$BIN_DIR/mise" != "$(command -v mise 2>/dev/null)" ]; then
      brew_install mise
      ln -sf "$(command -v mise)" "$BIN_DIR/mise"
    else
      curl -fsSL https://mise.run | MISE_INSTALL_PATH="$BIN_DIR/mise" sh
    fi
    INSTALLED+=(mise)
  fi
fi

# ------------------------------------------------------------------ summary --

log "Summary"
if [ "${#MISSING[@]}" -eq 0 ]; then
  echo "  Everything .zshrc needs is already in place."
elif [ "$CHECK" -eq 1 ]; then
  echo "  Missing: ${MISSING[*]}"
  echo "  Re-run without --check to install them."
  exit 1
else
  echo "  Installed: ${INSTALLED[*]}"
fi

# .zshrc sets EDITOR and prepends to PATH only when ~/.local/nvim exists.
if [ ! -d "$HOME/.local/nvim" ]; then
  echo "  Note: ~/.local/nvim is absent, so .zshrc leaves \$EDITOR unset."
  echo "        Install neovim there, or via mise: mise use -g neovim@latest"
fi

if [ "$CHECK" -eq 0 ]; then
  log "Verifying"
  out=$(zsh -i -c 'exit' 2>&1 </dev/null || true)
  problems=$(printf '%s\n' "$out" | grep -Ei 'not found|no such file|parse error' || true)
  if [ -n "$problems" ]; then
    warn "a new interactive zsh still complains:"
    printf '%s\n' "$problems" | sed 's/^/    /'
    exit 1
  fi
  ok "interactive zsh starts cleanly"
  echo
  echo "Open a new shell, or run: exec zsh -l"
fi
