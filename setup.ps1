
<#
.SYNOPSIS
    AI Engineering Toolchain Bootstrap

.DESCRIPTION
    Installs and configures the AI development stack for a project.

    Toolchain:
      - Python
      - Node.js
      - npm
      - Git
      - uv
      - Serena
      - Graphify
      - Codeburn
      - OpenSpec
      - OpenSpec UI
      - CodeGraph
      - APM

    Project initialization:
      - Git submodules
      - OCP Excellence -> Kiro Steering
      - Serena
      - CodeGraph
      - Graphify
      - OpenSpec
      - APM -> Kiro
      - Skills
      - Agents
      - Hooks
      - Steering files

.EXAMPLE
    .\setup.ps1

.EXAMPLE
    .\setup.ps1 -ProjectPath "C:\dev\customers\arcteryx\platform-reservation-api"

.EXAMPLE
    .\setup.ps1 -ProjectPath "C:\dev\customers\arcteryx\platform-reservation-api" -Force

.NOTES
    Requires:
      - Windows
      - PowerShell 7+
      - Internet connection
      - Git repository
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# ============================================================
# Configuration
# ============================================================

$ErrorActionPreference = "Stop"

$ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)
$ProjectName = Split-Path $ProjectPath -Leaf

$LogDirectory = Join-Path $ProjectPath "logs"
$LogFile = Join-Path $LogDirectory "ai-stack-install.log"

$OcpExcellenceRepository = `
    "https://github.com/arcteryx-ocp/ocp-excellence.git"

$OcpExcellencePath = `
    "external/ocp-excellence"

$OcpExcellenceFullPath = `
    Join-Path $ProjectPath $OcpExcellencePath

$GitModulesFile = `
    Join-Path $ProjectPath ".gitmodules"

$SerenaDirectory = `
    Join-Path $ProjectPath ".serena"

$SerenaProjectFile = `
    Join-Path $SerenaDirectory "project.yml"

$SerenaGlobalDirectory = `
    Join-Path $env:USERPROFILE ".serena"

$SerenaGlobalConfig = `
    Join-Path $SerenaGlobalDirectory "serena_config.yml"

$KiroDirectory = `
    Join-Path $ProjectPath ".kiro"

$KiroSteeringDirectory = `
    Join-Path $KiroDirectory "steering"

$MinVersions = @{
    python = [version]"3.13.0"
    node   = [version]"20.0.0"
    npm    = [version]"10.0.0"
    git    = [version]"2.40.0"
    uv     = [version]"0.7.0"
}

# ============================================================
# Logging
# ============================================================

New-Item `
    -ItemType Directory `
    -Force `
    -Path $LogDirectory |
    Out-Null

Start-Transcript `
    -Path $LogFile `
    -Append |
    Out-Null

# ============================================================
# Helper functions
# ============================================================

function Write-Info {
    param(
        [string]$Message
    )

    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param(
        [string]$Message
    )

    Write-Host "[ OK ] $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param(
        [string]$Message
    )

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param(
        [string]$Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-CommandExists {
    param(
        [Parameter(Mandatory)]
        [string]$Command
    )

    return $null -ne (
        Get-Command `
            $Command `
            -ErrorAction SilentlyContinue
    )
}

function Invoke-ExternalCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @()
    )

    Write-Info "$Command $($Arguments -join ' ')"

    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {

        throw `
            "Command failed: $Command $($Arguments -join ' ') ExitCode=$LASTEXITCODE"
    }
}

function Get-ToolVersion {
    param(
        [Parameter(Mandatory)]
        [string]$Tool
    )

    switch ($Tool) {

        "python" {
            return (
                python --version 2>&1
            ).ToString().Split(" ")[1]
        }

        "node" {
            return (
                node --version
            ).ToString().TrimStart("v")
        }

        "npm" {
            return (
                npm --version 2>&1
            ).ToString().Trim()
        }

        "git" {
            $value = (
                git --version 2>&1
            ).ToString()

            return $value.Split(" ")[2]
        }

        "uv" {
            $value = (
                uv --version 2>&1
            ).ToString()

            return $value.Split(" ")[1]
        }

        default {
            throw "Unknown tool: $Tool"
        }
    }
}

function Test-ToolVersion {
    param(
        [Parameter(Mandatory)]
        [string]$Tool,

        [Parameter(Mandatory)]
        [version]$MinimumVersion
    )

    if (-not (Test-CommandExists $Tool)) {

        throw `
            "$Tool is not installed or is not available in PATH."
    }

    $versionString = Get-ToolVersion $Tool

    if ($versionString -match '^(\d+\.\d+\.\d+)') {

        $version = [version]$Matches[1]
    }
    else {

        throw `
            "Unable to parse $Tool version: $versionString"
    }

    if ($version -lt $MinimumVersion) {

        throw `
            "$Tool version $version is below required version $MinimumVersion."
    }

    Write-Success "$Tool $version OK"
}

function Test-NpmPackageInstalled {
    param(
        [Parameter(Mandatory)]
        [string]$Package
    )

    try {

        npm list `
            -g `
            $Package `
            --depth=0 `
            2>$null |
            Out-Null

        return $LASTEXITCODE -eq 0

    }
    catch {

        return $false
    }
}

function Install-NpmPackage {
    param(
        [Parameter(Mandatory)]
        [string]$Package
    )

    if (
        (Test-NpmPackageInstalled $Package) `
        -and `
        -not $Force
    ) {

        Write-Success "$Package already installed."

        return
    }

    Write-Info "Installing npm package: $Package"

    Invoke-ExternalCommand `
        -Command "npm" `
        -Arguments @(
            "install",
            "-g",
            $Package
        )

    Write-Success "$Package installed."
}

function Test-SerenaProjectConfig {
    param(
        [Parameter(Mandatory)]
        [string]$ConfigFile
    )

    if (-not (Test-Path $ConfigFile)) {

        return $false
    }

    try {

        $Content = `
            Get-Content `
                $ConfigFile `
                -Raw `
                -ErrorAction Stop

        if (
            [string]::IsNullOrWhiteSpace($Content)
        ) {

            return $false
        }

        if (
            $Content -notmatch "(?m)^languages\s*:"
        ) {

            return $false
        }

        return $true

    }
    catch {

        return $false
    }
}

function Test-GitSubmoduleRegistered {
    param(
        [Parameter(Mandatory)]
        [string]$SubmodulePath
    )

    if (-not (Test-Path $GitModulesFile)) {

        return $false
    }

    $PathValue = `
        git config `
            --file .gitmodules `
            --get-regexp `
            "^submodule\..*\.path$" `
            2>$null

    if (-not $PathValue) {

        return $false
    }

    foreach ($Line in $PathValue) {

        if (
            $Line -match `
                "\s+$([regex]::Escape($SubmodulePath))$"
        ) {

            return $true
        }
    }

    return $false
}

# ============================================================
# Banner
# ============================================================

Clear-Host

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " AI Engineering Toolchain Bootstrap" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Project : $ProjectPath"
Write-Host "Name    : $ProjectName"
Write-Host "Force   : $Force"
Write-Host "Log     : $LogFile"
Write-Host ""

# ============================================================
# Stage 0
# Validate project
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 0 - Project Validation"
Write-Host "============================================================"
Write-Host ""

Write-Info "Validating project..."

if (-not (Test-Path $ProjectPath)) {

    throw `
        "Project path does not exist: $ProjectPath"
}

if (
    -not (
        Test-Path `
            (Join-Path $ProjectPath ".git")
    )
) {

    throw `
        "Target directory is not a Git repository: $ProjectPath"
}

Set-Location $ProjectPath

$GitRoot = `
    (
        git rev-parse --show-toplevel 2>$null
    ).Trim()

if (
    $LASTEXITCODE -ne 0 `
    -or `
    [string]::IsNullOrWhiteSpace($GitRoot)
) {

    throw `
        "Unable to determine Git repository root."
}

$GitRoot = `
    [System.IO.Path]::GetFullPath($GitRoot)

if (
    $GitRoot.TrimEnd('\') `
    -ne `
    $ProjectPath.TrimEnd('\')
) {

    throw @"
The specified ProjectPath is not the Git repository root.

ProjectPath:
$ProjectPath

Git root:
$GitRoot

Run the script using the repository root as ProjectPath.
"@
}

Write-Success "Git repository validated."

# ============================================================
# Stage 1
# Dependency verification
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 1 - Dependency Verification"
Write-Host "============================================================"
Write-Host ""

foreach ($Tool in $MinVersions.Keys) {

    Test-ToolVersion `
        -Tool $Tool `
        -MinimumVersion $MinVersions[$Tool]
}

# ============================================================
# Stage 2
# Install uv if missing
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 2 - Base Tooling"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-CommandExists "uv")) {

    Write-Info "uv is not installed."

    Write-Info "Installing uv..."

    irm `
        https://astral.sh/uv/install.ps1 |
        iex

    $env:Path = `
        [System.Environment]::GetEnvironmentVariable(
            "Path",
            "User"
        ) + ";" +
        [System.Environment]::GetEnvironmentVariable(
            "Path",
            "Machine"
        )

    if (-not (Test-CommandExists "uv")) {

        throw @"
uv was installed but is not available in PATH.

Restart PowerShell and run the script again.
"@
    }

    Write-Success "uv installed."

}
else {

    Write-Success "uv already installed."
}

# ============================================================
# Stage 3
# Global AI Tools
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 3 - Global AI Tools"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# Serena
# ------------------------------------------------------------

if (
    (Test-CommandExists "serena") `
    -and `
    -not $Force
) {

    Write-Success "Serena already installed."

}
else {

    Write-Info "Installing/upgrading Serena..."

    Invoke-ExternalCommand `
        -Command "uv" `
        -Arguments @(
            "tool",
            "install",
            "-p",
            "3.13",
            "serena-agent"
        )

    Write-Success "Serena installed."
}

# ------------------------------------------------------------
# Graphify
# ------------------------------------------------------------

if (
    (Test-CommandExists "graphify") `
    -and `
    -not $Force
) {

    Write-Success "Graphify already installed."

}
else {

    Write-Info "Installing Graphify..."

    Invoke-ExternalCommand `
        -Command "uv" `
        -Arguments @(
            "tool",
            "install",
            "graphify"
        )

    Write-Info "Installing Graphify Windows integration..."

    Invoke-ExternalCommand `
        -Command "graphify" `
        -Arguments @(
            "install",
            "--platform",
            "windows"
        )

    Write-Success "Graphify installed."
}

# ------------------------------------------------------------
# Codeburn
# ------------------------------------------------------------

Install-NpmPackage "codeburn"

# ------------------------------------------------------------
# OpenSpec
# ------------------------------------------------------------

Install-NpmPackage "@fission-ai/openspec@latest"

# ------------------------------------------------------------
# OpenSpec UI
# ------------------------------------------------------------

Install-NpmPackage "openspecui"

# ------------------------------------------------------------
# CodeGraph
# ------------------------------------------------------------

if (
    (Test-CommandExists "codegraph") `
    -and `
    -not $Force
) {

    Write-Success "CodeGraph already installed."

}
else {

    Write-Info "Installing CodeGraph..."

    Invoke-Expression `
        (
            Invoke-RestMethod `
                "https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1"
        )

    Write-Success "CodeGraph installation completed."
}

# ============================================================
# Stage 4
# Graphify integrations
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 4 - Graphify Integrations"
Write-Host "============================================================"
Write-Host ""

if (Test-CommandExists "graphify") {

    Write-Info "Installing Graphify Claude integration..."

    try {

        Invoke-ExternalCommand `
            -Command "graphify" `
            -Arguments @(
                "claude",
                "install"
            )

        Write-Success `
            "Graphify Claude integration installed."

    }
    catch {

        Write-WarningMessage `
            "Graphify Claude integration failed."
    }

    Write-Info "Installing Graphify Cursor integration..."

    try {

        Invoke-ExternalCommand `
            -Command "graphify" `
            -Arguments @(
                "cursor",
                "install"
            )

        Write-Success `
            "Graphify Cursor integration installed."

    }
    catch {

        Write-WarningMessage `
            "Graphify Cursor integration failed."
    }
}

# ============================================================
# Stage 5
# Git Submodules
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 5 - Git Submodules"
Write-Host "============================================================"
Write-Host ""

Write-Info "Configuring OCP Excellence Git submodule..."

# ------------------------------------------------------------
# Check unresolved conflicts
# ------------------------------------------------------------

$UnmergedFiles = `
    git diff --name-only --diff-filter=U

if ($LASTEXITCODE -ne 0) {

    throw `
        "Unable to check Git merge conflicts."
}

if ($UnmergedFiles) {

    Write-ErrorMessage `
        "Git contains unresolved merge conflicts:"

    $UnmergedFiles | ForEach-Object {

        Write-Host "  $_"
    }

    if (
        $UnmergedFiles -contains ".gitmodules"
    ) {

        throw @"
.gitmodules has an unresolved merge conflict.

Resolve the conflict first.

Then run:

    git add .gitmodules

After that run this bootstrap again.
"@
    }

    throw `
        "Resolve all Git merge conflicts before running the bootstrap."
}

# ------------------------------------------------------------
# Handle .gitmodules missing from working tree
# ------------------------------------------------------------

$GitModulesTracked = `
    git ls-files `
        --error-unmatch `
        .gitmodules `
        2>$null

if (
    $LASTEXITCODE -eq 0 `
    -and `
    -not (Test-Path $GitModulesFile)
) {

    Write-WarningMessage `
        ".gitmodules is tracked but missing from working tree."

    if ($Force) {

        Write-Info `
            "Force mode enabled. Restoring .gitmodules..."

        Invoke-ExternalCommand `
            -Command "git" `
            -Arguments @(
                "restore",
                "--source=HEAD",
                "--",
                ".gitmodules"
            )

    }
    else {

        throw @"
.gitmodules is tracked by Git but missing from the working tree.

Run:

    git restore .gitmodules

or:

    .\setup.ps1 -Force
"@
    }
}

# ------------------------------------------------------------
# Handle empty .gitmodules
# ------------------------------------------------------------

if (Test-Path $GitModulesFile) {

    $GitModulesContent = `
        Get-Content `
            $GitModulesFile `
            -Raw `
            -ErrorAction Stop

    if (
        [string]::IsNullOrWhiteSpace(
            $GitModulesContent
        )
    ) {

        Write-WarningMessage `
            ".gitmodules exists but is empty."

        if ($Force) {

            Remove-Item `
                -Force `
                $GitModulesFile

        }
        else {

            throw @"
.gitmodules exists but is empty.

Remove it or run:

    .\setup.ps1 -Force
"@
        }
    }
}

# ------------------------------------------------------------
# Create external directory
# ------------------------------------------------------------

$ExternalDirectory = `
    Join-Path $ProjectPath "external"

if (-not (Test-Path $ExternalDirectory)) {

    Write-Info "Creating external directory..."

    New-Item `
        -ItemType Directory `
        -Path $ExternalDirectory `
        -Force |
        Out-Null
}

# ------------------------------------------------------------
# Check existing submodule
# ------------------------------------------------------------

$SubmoduleRegistered = `
    Test-GitSubmoduleRegistered `
        -SubmodulePath $OcpExcellencePath

if ($SubmoduleRegistered) {

    Write-Success `
        "OCP Excellence is already registered as a Git submodule."

}
else {

    # --------------------------------------------------------
    # Check stale target directory
    # --------------------------------------------------------

    if (Test-Path $OcpExcellenceFullPath) {

        Write-WarningMessage `
            "Target directory already exists:"

        Write-Host "  $OcpExcellenceFullPath"

        if ($Force) {

            Write-Info `
                "Force mode enabled. Removing stale directory..."

            Remove-Item `
                -Recurse `
                -Force `
                $OcpExcellenceFullPath

        }
        else {

            throw @"
The target submodule directory already exists:

$OcpExcellenceFullPath

If it is not a valid Git submodule, remove it or run:

    .\setup.ps1 -Force
"@
        }
    }

    # --------------------------------------------------------
    # Add submodule
    # --------------------------------------------------------

    Write-Info "Adding dev-standards submodule..."

    Invoke-ExternalCommand `
        -Command "git" `
        -Arguments @(
            "submodule",
            "add",
            $OcpExcellenceRepository,
            $OcpExcellencePath
        )

    Write-Success `
        "OCP Excellence submodule added."
}

# ------------------------------------------------------------
# Sync submodule
# ------------------------------------------------------------

Write-Info "Synchronizing Git submodules..."

Invoke-ExternalCommand `
    -Command "git" `
    -Arguments @(
        "submodule",
        "sync",
        "--recursive"
    )

Write-Info "Initializing Git submodules..."

Invoke-ExternalCommand `
    -Command "git" `
    -Arguments @(
        "submodule",
        "update",
        "--init",
        "--recursive"
    )

# ------------------------------------------------------------
# Verify
# ------------------------------------------------------------

if (-not (Test-Path $OcpExcellenceFullPath)) {

    throw @"
OCP Excellence submodule was registered but its directory does not exist:

$OcpExcellenceFullPath
"@
}

$SubmoduleStatus = `
    git submodule status `
        -- $OcpExcellencePath

Write-Host ""
Write-Host "OCP Excellence:"
Write-Host "  Repository : $OcpExcellenceRepository"
Write-Host "  Path       : $OcpExcellencePath"
Write-Host "  Status     : $SubmoduleStatus"
Write-Host ""

Write-Success `
    "Git submodule configured successfully."

# ============================================================
# Stage 6
# OCP Excellence -> Kiro Steering
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 6 - OCP Excellence -> Kiro Steering"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# Create Kiro directories
# ------------------------------------------------------------

if (-not (Test-Path $KiroDirectory)) {

    Write-Info "Creating .kiro directory..."

    New-Item `
        -ItemType Directory `
        -Path $KiroDirectory `
        -Force |
        Out-Null
}

if (-not (Test-Path $KiroSteeringDirectory)) {

    Write-Info `
        "Creating .kiro/steering directory..."

    New-Item `
        -ItemType Directory `
        -Path $KiroSteeringDirectory `
        -Force |
        Out-Null
}

# ------------------------------------------------------------
# Locate steering files
# ------------------------------------------------------------

Write-Info `
    "Searching OCP Excellence for Kiro steering files..."

$SteeringSources = @()

$PotentialSteeringDirectories = @(
    (Join-Path $OcpExcellenceFullPath ".kiro\steering"),
    (Join-Path $OcpExcellenceFullPath "steering"),
    (Join-Path $OcpExcellenceFullPath "docs\steering")
)

foreach ($Directory in $PotentialSteeringDirectories) {

    if (Test-Path $Directory) {

        Write-Info "Found steering directory:"
        Write-Host "  $Directory"

        $SteeringSources += $Directory
    }
}

# ------------------------------------------------------------
# Copy steering files
# ------------------------------------------------------------

if ($SteeringSources.Count -eq 0) {

    Write-WarningMessage `
        "No known steering directory was found in OCP Excellence."

}
else {

    foreach ($Source in $SteeringSources) {

        Write-Info `
            "Copying steering files from: $Source"

        Copy-Item `
            -Path (Join-Path $Source "*") `
            -Destination $KiroSteeringDirectory `
            -Recurse `
            -Force

        Write-Success `
            "Steering files copied to .kiro/steering."
    }
}

# ------------------------------------------------------------
# List steering files
# ------------------------------------------------------------

if (Test-Path $KiroSteeringDirectory) {

    Write-Info `
        "Installed Kiro steering files:"

    Get-ChildItem `
        $KiroSteeringDirectory `
        -Recurse `
        -File |
        ForEach-Object {

            $RelativePath = `
                $_.FullName.Substring(
                    $ProjectPath.Length + 1
                )

            Write-Host "  $RelativePath"
        }
}

Write-Success `
    "OCP Excellence steering setup completed."

# ============================================================
# Stage 7
# Serena Project
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 7 - Serena Project"
Write-Host "============================================================"
Write-Host ""

Write-Info `
    "Initializing Serena project: $ProjectName"

# ------------------------------------------------------------
# Existing project validation
# ------------------------------------------------------------

if (Test-Path $SerenaProjectFile) {

    Write-Info `
        "Existing Serena project found:"

    Write-Host "  $SerenaProjectFile"

    if (
        -not (
            Test-SerenaProjectConfig `
                -ConfigFile $SerenaProjectFile
        )
    ) {

        Write-WarningMessage `
            "Serena project.yml is invalid or missing 'languages'."

        if ($Force) {

            Write-WarningMessage `
                "Force mode enabled. Removing invalid Serena project."

            Remove-Item `
                -Recurse `
                -Force `
                $SerenaDirectory

        }
        else {

            throw @"
Invalid Serena project configuration.

File:
$SerenaProjectFile

The configuration does not contain the required 'languages'
property.

Run:

    .\setup.ps1 -Force
"@
        }
    }
}

# ------------------------------------------------------------
# Create Serena project
# ------------------------------------------------------------

if (-not (Test-Path $SerenaProjectFile)) {

    Write-Info `
        "Creating Serena project..."

    Invoke-ExternalCommand `
        -Command "serena" `
        -Arguments @(
            "project",
            "create",
            "--name",
            $ProjectName
        )

    Write-Success `
        "Serena project created."
}
else {

    Write-Success `
        "Serena project already exists."
}

# ------------------------------------------------------------
# Validate project configuration
# ------------------------------------------------------------

if (
    -not (
        Test-SerenaProjectConfig `
            -ConfigFile $SerenaProjectFile
    )
) {

    throw @"
Serena project was created but project.yml is invalid.

Expected file:

$SerenaProjectFile

The file must contain:

languages:
  - ...

Check the Serena version and project configuration.
"@
}

# ------------------------------------------------------------
# Index project
# ------------------------------------------------------------

Write-Info `
    "Indexing Serena project..."

Invoke-ExternalCommand `
    -Command "serena" `
    -Arguments @(
        "project",
        "index"
    )

Write-Success `
    "Serena project indexed successfully."

# ============================================================
# Stage 8
# Serena Global Configuration
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 8 - Serena Global Configuration"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path $SerenaGlobalConfig)) {

    Write-Info `
        "Initializing Serena global configuration..."

    Invoke-ExternalCommand `
        -Command "serena" `
        -Arguments @(
            "init"
        )

    Write-Success `
        "Serena global configuration initialized."

}
else {

    Write-Success `
        "Serena global configuration already exists."
}

# ============================================================
# Stage 9
# CodeGraph
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 9 - CodeGraph"
Write-Host "============================================================"
Write-Host ""

if (
    -not (Test-Path ".codegraph") `
    -or `
    $Force
) {

    Write-Info `
        "Initializing CodeGraph..."

    Invoke-ExternalCommand `
        -Command "codegraph" `
        -Arguments @(
            "init",
            "-i"
        )

    Write-Success `
        "CodeGraph initialized."

}
else {

    Write-Success `
        "CodeGraph already initialized."
}

# ============================================================
# Stage 10
# Graphify Project
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 10 - Graphify Project"
Write-Host "============================================================"
Write-Host ""

Write-Info `
    "Running Graphify..."

try {

    Invoke-ExternalCommand `
        -Command "graphify" `
        -Arguments @(
            "."
        )

    Write-Success `
        "Graphify extraction completed."

}
catch {

    Write-WarningMessage `
        "Graphify extraction returned an error."

    Write-WarningMessage `
        "This may happen when documents/images require an LLM API key."

    Write-WarningMessage `
        "Supported environment variables include:"

    Write-Host "  GEMINI_API_KEY"
    Write-Host "  GOOGLE_API_KEY"
    Write-Host "  MOONSHOT_API_KEY"
    Write-Host "  ANTHROPIC_API_KEY"
    Write-Host "  OPENAI_API_KEY"
    Write-Host "  DEEPSEEK_API_KEY"
}

# ------------------------------------------------------------
# Graphify hook
# ------------------------------------------------------------

Write-Info `
    "Installing Graphify hook..."

try {

    Invoke-ExternalCommand `
        -Command "graphify" `
        -Arguments @(
            "hook",
            "install"
        )

    Write-Success `
        "Graphify hook installed."

}
catch {

    Write-WarningMessage `
        "Graphify hook installation failed."
}

# ============================================================
# Stage 11
# OpenSpec
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 11 - OpenSpec"
Write-Host "============================================================"
Write-Host ""

if (
    -not (Test-Path "openspec") `
    -or `
    $Force
) {

    Write-Info `
        "Initializing OpenSpec for Kiro..."

    Invoke-ExternalCommand `
        -Command "openspec" `
        -Arguments @(
            "init",
            "--tools",
            "kiro"
        )

    Write-Success `
        "OpenSpec initialized."

}
else {

    Write-Success `
        "OpenSpec already initialized."
}

# ============================================================
# Stage 12
# APM
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 12 - APM"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-CommandExists "apm")) {

    Write-WarningMessage `
        "APM is not installed."

    Write-WarningMessage `
        "Install Microsoft APM before continuing."

    Write-Host ""
    Write-Host "Example:"
    Write-Host "  npm install -g @microsoft/apm"
    Write-Host ""

    throw `
        "APM command not found."
}

Write-Success `
    "APM detected."

# ------------------------------------------------------------
# Install APM components for Kiro
# ------------------------------------------------------------

Write-Info `
    "Installing APM package for Kiro..."

Invoke-ExternalCommand `
    -Command "apm" `
    -Arguments @(
        "install",
        "--target",
        "kiro"
    )

Write-Success `
    "APM components installed."

# ============================================================
# Stage 13
# OpenSpec Update
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 13 - OpenSpec Update"
Write-Host "============================================================"
Write-Host ""

Write-Info `
    "Updating OpenSpec..."

Invoke-ExternalCommand `
    -Command "openspec" `
    -Arguments @(
        "update"
    )

Write-Success `
    "OpenSpec updated."

# ============================================================
# Stage 14
# Final Verification
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 14 - Final Verification"
Write-Host "============================================================"
Write-Host ""

$Tools = @(
    "python",
    "node",
    "npm",
    "git",
    "uv",
    "serena",
    "graphify",
    "codeburn",
    "openspec",
    "openspecui",
    "codegraph",
    "apm"
)

foreach ($Tool in $Tools) {

    if (Test-CommandExists $Tool) {

        try {

            $Version = switch ($Tool) {

                "python" {
                    python --version 2>&1
                }

                "node" {
                    node --version
                }

                "npm" {
                    npm --version
                }

                "git" {
                    git --version
                }

                "uv" {
                    uv --version
                }

                default {
                    "installed"
                }
            }

            Write-Success `
                "$Tool : $Version"

        }
        catch {

            Write-Success `
                "$Tool : installed"
        }

    }
    else {

        Write-WarningMessage `
            "$Tool : NOT FOUND"
    }
}

# ============================================================
# Verify project artifacts
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Project Artifacts"
Write-Host "============================================================"
Write-Host ""

$Artifacts = @(
    ".git",
    ".gitmodules",
    ".codegraph",
    "openspec",
    ".kiro",
    ".serena",
    "external/ocp-excellence"
)

foreach ($Artifact in $Artifacts) {

    if (Test-Path $Artifact) {

        Write-Success `
            $Artifact

    }
    else {

        Write-WarningMessage `
            "$Artifact not found."
    }
}

# ============================================================
# Verify Git Submodule
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Git Submodule Verification"
Write-Host "============================================================"
Write-Host ""

if (
    Test-GitSubmoduleRegistered `
        -SubmodulePath $OcpExcellencePath
) {

    Write-Success `
        "OCP Excellence registered in .gitmodules."

}
else {

    Write-WarningMessage `
        "OCP Excellence is not registered in .gitmodules."
}

if (Test-Path $OcpExcellenceFullPath) {

    Write-Success `
        "OCP Excellence directory exists."

}
else {

    Write-WarningMessage `
        "OCP Excellence directory does not exist."
}

# ============================================================
# Final summary
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " Installation completed successfully" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Project:"
Write-Host "  $ProjectPath"

Write-Host ""

Write-Host "Git:"
Write-Host "  Submodule:"
Write-Host "    external/ocp-excellence"

Write-Host ""

Write-Host "AI components:"
Write-Host "  APM -> Kiro"
Write-Host "  Skills"
Write-Host "  Agents"
Write-Host "  Hooks"
Write-Host "  Steering"

Write-Host ""

Write-Host "Development tools:"
Write-Host "  Serena"
Write-Host "  Graphify"
Write-Host "  CodeGraph"
Write-Host "  Codeburn"
Write-Host "  OpenSpec"

Write-Host ""

Write-Host "Project directories:"
Write-Host "  .serena/"
Write-Host "  .kiro/"
Write-Host "  openspec/"
Write-Host "  .codegraph/"
Write-Host "  external/ocp-excellence/"

Write-Host ""

Write-Host "Log:"
Write-Host "  $LogFile"

Write-Host ""

Write-Host "Recommended next steps:" -ForegroundColor Cyan
Write-Host ""

Write-Host "  1. Review Graphify:"
Write-Host "     graphify-out/GRAPH_REPORT.md"

Write-Host ""

Write-Host "  2. Review Kiro:"
Write-Host "     .kiro/"

Write-Host ""

Write-Host "  3. Review OpenSpec:"
Write-Host "     openspec/"

Write-Host ""

Write-Host "  4. Check APM:"
Write-Host "     apm audit"

Write-Host ""

# ============================================================
# OpenSpec Profile Configuration Hint
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host " OpenSpec Profile Configuration - HINT" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "OpenSpec supports different workflow profiles." -ForegroundColor Cyan
Write-Host ""

Write-Host "If you want to configure the Workflow Patterns / Expanded Mode"
Write-Host "profile manually, run the following command from the project root:"
Write-Host ""

Write-Host "    openspec config profile" -ForegroundColor White
Write-Host ""

Write-Host "NOTE:" -ForegroundColor Yellow
Write-Host "This command is interactive and is intentionally not"
Write-Host "automatically configured by this bootstrap script."
Write-Host ""

Write-Host "After selecting the desired profile, run:"
Write-Host ""

Write-Host "    openspec update" -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""

# ============================================================
# Finish
# ============================================================

Stop-Transcript | Out-Null

