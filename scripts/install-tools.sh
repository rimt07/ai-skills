```bash
#!/usr/bin/env bash

# ============================================================
# AI Development Stack Installer
#
# Installs and configures:
#   - Serena
#   - Graphify
#   - Codeburn
#   - OpenSpec
#   - OpenSpec UI
#   - Claude Code History Viewer
#   - CodeGraph
#
# Initializes:
#   - Git submodules
#   - Serena
#   - CodeGraph
#   - Graphify
#   - OpenSpec
#   - Kiro skills
#
# Usage:
#   ./install-ai-stack.sh /path/to/project
#
# Example:
#   ./install-ai-stack.sh ~/dev/platform-reservation-api
#
# Optional:
#   FORCE=true ./install-ai-stack.sh ~/dev/platform-reservation-api
# ============================================================

set -Eeuo pipefail

# ============================================================
# Configuration
# ============================================================

FORCE="${FORCE:-false}"

PROJECT_PATH="${1:-}"

PROJECT_NAME=""

LOG_DIR="${PWD}/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_DIR}/ai-stack-install.log"

# Repository configuration
DEV_STANDARDS_REPO="https://github.com/enterprise-repo/dev-standards.git"
DEV_STANDARDS_PATH="external/dev-standards"

AI_SKILLS_REPO="rimt07/ai-skills"

# Minimum versions
MIN_PYTHON="3.13.0"
MIN_NODE="20.0.0"
MIN_NPM="10.0.0"
MIN_GIT="2.40.0"
MIN_UV="0.7.0"

# ============================================================
# Logging
# ============================================================

exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

info() {
    echo "[INFO] $*"
}

success() {
    echo "[ OK ] $*"
}

warning() {
    echo "[WARN] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
}

fail() {
    error "$*"
    exit 1
}

# ============================================================
# Error handling
# ============================================================

on_error() {
    local exit_code=$?
    error "Installation failed at line ${BASH_LINENO[0]}."
    error "Exit code: ${exit_code}"
    error "Check log: ${LOG_FILE}"
}

trap on_error ERR

# ============================================================
# Utility functions
# ============================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

version_ge() {
    # Returns true when $1 >= $2
    printf '%s\n%s\n' "$2" "$1" |
        sort -V -C
}

get_version() {
    local tool="$1"

    case "$tool" in
        python|python3)
            python3 --version 2>&1 | awk '{print $2}'
            ;;

        node)
            node --version 2>&1 | sed 's/^v//'
            ;;

        npm)
            npm --version 2>&1
            ;;

        git)
            git --version 2>&1 | awk '{print $3}'
            ;;

        uv)
            uv --version 2>&1 | awk '{print $2}'
            ;;

        *)
            echo ""
            ;;
    esac
}

check_version() {
    local tool="$1"
    local minimum="$2"

    if ! command_exists "$tool"; then
        fail "$tool is not installed or is not available in PATH."
    fi

    local version
    version="$(get_version "$tool")"

    if [[ -z "$version" ]]; then
        fail "Unable to determine version for $tool."
    fi

    # Extract major.minor.patch
    version="$(echo "$version" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+' || true)"

    if [[ -z "$version" ]]; then
        fail "Unable to parse version for $tool."
    fi

    if ! version_ge "$version" "$minimum"; then
        fail "$tool version $version is below required version $minimum."
    fi

    success "$tool $version OK"
}

install_uv() {
    if command_exists uv; then
        success "uv already installed."
        return
    fi

    log "Installing uv..."

    curl -LsSf https://astral.sh/uv/install.sh | sh

    export PATH="$HOME/.local/bin:$PATH"

    if ! command_exists uv; then
        fail "uv installation completed but uv is not available in PATH."
    fi

    success "uv installed."
}

# ============================================================
# Banner
# ============================================================

clear 2>/dev/null || true

echo "============================================================"
echo " AI Development Stack Installer"
echo "============================================================"
echo
echo "Force reinstall: ${FORCE}"
echo "Log file:        ${LOG_FILE}"
echo

# ============================================================
# Validate project argument
# ============================================================

if [[ -z "$PROJECT_PATH" ]]; then
    fail "Project path is required.

Usage:
  ./install-ai-stack.sh /path/to/project

Example:
  ./install-ai-stack.sh ~/dev/platform-reservation-api"
fi

PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_PATH")"

if [[ ! -d "$PROJECT_PATH" ]]; then
    fail "Project directory does not exist: $PROJECT_PATH"
fi

if [[ ! -d "$PROJECT_PATH/.git" ]]; then
    fail "Target directory is not a Git repository: $PROJECT_PATH"
fi

# ============================================================
# Stage 1 - Dependency verification
# ============================================================

log "Stage 1 - Verifying dependencies"

check_version python3 "$MIN_PYTHON"
check_version node "$MIN_NODE"
check_version npm "$MIN_NPM"
check_version git "$MIN_GIT"

# uv may not exist in a fresh environment.
if command_exists uv; then
    check_version uv "$MIN_UV"
else
    warning "uv is not installed."
    install_uv
    check_version uv "$MIN_UV"
fi

# ============================================================
# Stage 2 - Global tools
# ============================================================

log "Stage 2 - Installing global tools"

# ------------------------------------------------------------
# Serena
# ------------------------------------------------------------

if command_exists serena && [[ "$FORCE" != "true" ]]; then
    success "Serena already installed."
else
    info "Installing Serena..."

    uv tool install -p 3.13 serena-agent

    success "Serena installed."
fi

# ------------------------------------------------------------
# Graphify
# ------------------------------------------------------------

if command_exists graphify && [[ "$FORCE" != "true" ]]; then
    success "Graphify already installed."
else
    info "Installing Graphify..."

    uv tool install graphify

    if command_exists graphify; then
        graphify install --platform linux || warning "Graphify platform installation returned a non-zero exit code."
    fi

    success "Graphify installed."
fi

# ------------------------------------------------------------
# Codeburn
# ------------------------------------------------------------

if command_exists codeburn && [[ "$FORCE" != "true" ]]; then
    success "Codeburn already installed."
else
    info "Installing Codeburn..."

    npm install -g codeburn

    success "Codeburn installed."
fi

# ------------------------------------------------------------
# OpenSpec
# ------------------------------------------------------------

if command_exists openspec && [[ "$FORCE" != "true" ]]; then
    success "OpenSpec already installed."
else
    info "Installing OpenSpec..."

    npm install -g @fission-ai/openspec@latest

    success "OpenSpec installed."
fi

# ------------------------------------------------------------
# OpenSpec UI
# ------------------------------------------------------------

if command_exists openspecui && [[ "$FORCE" != "true" ]]; then
    success "OpenSpec UI already installed."
else
    info "Installing OpenSpec UI..."

    npm install -g openspecui

    success "OpenSpec UI installed."
fi

# ------------------------------------------------------------
# Claude Code History Viewer
# ------------------------------------------------------------

info "Checking Claude Code History Viewer..."

if [[ "$OSTYPE" == "darwin"* ]]; then

    warning "Claude Code History Viewer installation is Windows-specific in the original notebook."
    warning "Skipping automatic installation on macOS."

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then

    warning "Claude Code History Viewer installation is Windows-specific in the original notebook."
    warning "Skipping automatic installation on Linux/WSL."

else

    warning "Unsupported OS for automatic Claude Code History Viewer installation."
    warning "Install it manually from:"
    echo "https://github.com/jhlee0409/claude-code-history-viewer"

fi

# ------------------------------------------------------------
# CodeGraph
# ------------------------------------------------------------

if command_exists codegraph && [[ "$FORCE" != "true" ]]; then
    success "CodeGraph already installed."
else
    info "Installing CodeGraph..."

    if command_exists curl; then
        curl -fsSL \
            https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh |
            bash
    else
        fail "curl is required to install CodeGraph."
    fi

    success "CodeGraph installed."
fi

# ------------------------------------------------------------
# Graphify integrations
# ------------------------------------------------------------

if command_exists graphify; then

    info "Installing Graphify integrations..."

    graphify claude install || \
        warning "Graphify Claude integration failed."

    graphify cursor install || \
        warning "Graphify Cursor integration failed."

    success "Graphify integrations processed."

fi

# ============================================================
# Stage 3 - Project initialization
# ============================================================

log "Stage 3 - Initializing project"

cd "$PROJECT_PATH"

info "Working directory:"
pwd

# ============================================================
# 3.1 Git submodule: dev-standards
# ============================================================

log "3.1 - Configuring dev-standards submodule"

if [[ ! -f ".gitmodules" ]] || [[ "$FORCE" == "true" ]]; then

    if [[ ! -d "$DEV_STANDARDS_PATH" ]]; then

        info "Adding dev-standards submodule..."

        git submodule add \
            "$DEV_STANDARDS_REPO" \
            "$DEV_STANDARDS_PATH"

    else

        warning "Submodule directory already exists."

    fi
fi

info "Initializing Git submodules..."

git submodule update --init --recursive

success "Git submodules initialized."

# ============================================================
# 3.2 Serena
# ============================================================

log "3.2 - Initializing Serena"

info "Creating Serena project: $PROJECT_NAME"

set +e

serena project create --name "$PROJECT_NAME"

SERENA_EXIT=$?

set -e

if [[ "$SERENA_EXIT" -ne 0 ]]; then

    warning "serena project create failed."

    info "Falling back to serena project index..."

    serena project index

    success "Serena project index completed."

else

    success "Serena project create completed."

fi

# ============================================================
# 3.3 CodeGraph
# ============================================================

log "3.3 - Initializing CodeGraph"

if [[ ! -d ".codegraph" ]] || [[ "$FORCE" == "true" ]]; then

    info "Initializing CodeGraph..."

    codegraph init -i

    success "CodeGraph initialized."

else

    success "CodeGraph already initialized."

fi

# ============================================================
# 3.4 Graphify
# ============================================================

log "3.4 - Initializing Graphify"

info "Running Graphify extraction..."

set +e

graphify .

GRAPHIFY_EXIT=$?

set -e

if [[ "$GRAPHIFY_EXIT" -ne 0 ]]; then

    warning "Graphify extraction returned exit code $GRAPHIFY_EXIT."

    warning "This can happen when documents/images require an LLM API key."

    warning "Supported API keys include:"
    echo "  GEMINI_API_KEY"
    echo "  GOOGLE_API_KEY"
    echo "  MOONSHOT_API_KEY"
    echo "  ANTHROPIC_API_KEY"
    echo "  OPENAI_API_KEY"
    echo "  DEEPSEEK_API_KEY"

else

    success "Graphify extraction completed."

fi

info "Installing Graphify git hook..."

graphify hook install

success "Graphify hook installed."

# ============================================================
# 3.5 OpenSpec
# ============================================================

log "3.5 - Initializing OpenSpec"

if [[ ! -d "openspec" ]] || [[ "$FORCE" == "true" ]]; then

    info "Initializing OpenSpec for Kiro..."

    openspec init --tools kiro

    success "OpenSpec initialized."

else

    success "OpenSpec already initialized."

fi

# ------------------------------------------------------------
# OpenSpec profile
# ------------------------------------------------------------

echo
echo "============================================================"
echo " OpenSpec Profile Configuration"
echo "============================================================"
echo
echo "The following command is interactive."
echo "Select the desired Workflow Patterns profile."
echo

read -r -p "Configure OpenSpec profile now? [y/N]: " CONFIGURE_OPENSPEC

if [[ "$CONFIGURE_OPENSPEC" =~ ^[Yy]$ ]]; then

    openspec config profile

else

    warning "OpenSpec profile configuration skipped."

fi

# ------------------------------------------------------------
# OpenSpec update
# ------------------------------------------------------------

info "Updating OpenSpec..."

openspec update

success "OpenSpec updated."

# ============================================================
# Final verification
# ============================================================

log "Final verification"

TOOLS=(
    "python3"
    "node"
    "npm"
    "git"
    "uv"
    "serena"
    "graphify"
    "codeburn"
    "openspec"
    "openspecui"
    "codegraph"
)

echo
echo "============================================================"
echo " Global Tools Status"
echo "============================================================"

for tool in "${TOOLS[@]}"; do

    if command_exists "$tool"; then

        VERSION=""

        case "$tool" in
            python3)
                VERSION="$(python3 --version 2>&1)"
                ;;
            node)
                VERSION="$(node --version 2>&1)"
                ;;
            npm)
                VERSION="$(npm --version 2>&1)"
                ;;
            git)
                VERSION="$(git --version 2>&1)"
                ;;
            uv)
                VERSION="$(uv --version 2>&1)"
                ;;
            *)
                VERSION="installed"
                ;;
        esac

        echo "[ OK ] $tool - $VERSION"

    else

        echo "[FAIL] $tool - NOT FOUND"

    fi

done

# ============================================================
# Project status
# ============================================================

echo
echo "============================================================"
echo " Project Status"
echo "============================================================"

echo "Project: $PROJECT_NAME"
echo "Path:    $PROJECT_PATH"

echo

if [[ -d ".codegraph" ]]; then
    echo "[ OK ] .codegraph"
else
    echo "[WARN] .codegraph not found"
fi

if [[ -d "openspec" ]]; then
    echo "[ OK ] openspec"
else
    echo "[WARN] openspec directory not found"
fi

if [[ -d ".git" ]]; then
    echo "[ OK ] Git repository"
else
    echo "[FAIL] Git repository"
fi

if [[ -d "$DEV_STANDARDS_PATH" ]]; then
    echo "[ OK ] $DEV_STANDARDS_PATH"
else
    echo "[WARN] $DEV_STANDARDS_PATH not found"
fi

# ============================================================
# Finished
# ============================================================

echo
echo "============================================================"
echo " Installation completed"
echo "============================================================"
echo
echo "Project:"
echo "  $PROJECT_PATH"
echo
echo "Log:"
echo "  $LOG_FILE"
echo

success "AI development stack installation completed."

echo
echo "Next recommended steps:"
echo
echo "  1. Review Graphify report:"
echo "     graphify-out/GRAPH_REPORT.md"
echo
echo "  2. Verify OpenSpec:"
echo "     openspec --help"
echo
echo "  3. Verify CodeGraph:"
echo "     codegraph --help"
echo
echo "  4. Verify Serena:"
echo "     serena --help"
echo
echo "============================================================"
```
