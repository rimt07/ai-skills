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

$DevStandardsRepository = "https://github.com/arcteryx-ocp/ocp-excellence.git"
$DevStandardsPath = "external/ocp-excellence"

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
    param([string]$Message)

    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)

    Write-Host "[ OK ] $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param([string]$Message)

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-CommandExists {
    param(
        [Parameter(Mandatory)]
        [string]$Command
    )

    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
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
        throw "Command failed: $Command $($Arguments -join ' ') ExitCode=$LASTEXITCODE"
    }
}

function Get-ToolVersion {
    param(
        [Parameter(Mandatory)]
        [string]$Tool
    )

    switch ($Tool) {

        "python" {
            return (python --version 2>&1).ToString().Split(" ")[1]
        }

        "node" {
            return (node --version).ToString().TrimStart("v")
        }

        "npm" {
            return (npm --version 2>&1).ToString().Trim()
        }

        "git" {
            $value = (git --version 2>&1).ToString()
            return $value.Split(" ")[2]
        }

        "uv" {
            $value = (uv --version 2>&1).ToString()
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
        throw "$Tool is not installed or is not available in PATH."
    }

    $versionString = Get-ToolVersion $Tool

    if ($versionString -match '^(\d+\.\d+\.\d+)') {
        $version = [version]$Matches[1]
    }
    else {
        throw "Unable to parse $Tool version: $versionString"
    }

    if ($version -lt $MinimumVersion) {
        throw "$Tool version $version is below required version $MinimumVersion."
    }

    Write-Success "$Tool $version OK"
}

function Test-NpmPackageInstalled {
    param(
        [Parameter(Mandatory)]
        [string]$Package
    )

    try {
        npm list -g $Package --depth=0 2>$null | Out-Null
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

    if ((Test-NpmPackageInstalled $Package) -and -not $Force) {

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
# Validate project
# ============================================================

Write-Info "Validating project..."

if (-not (Test-Path $ProjectPath)) {
    throw "Project path does not exist: $ProjectPath"
}

if (-not (Test-Path (Join-Path $ProjectPath ".git"))) {
    throw "Target directory is not a Git repository: $ProjectPath"
}

Set-Location $ProjectPath

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

if (-not (Test-CommandExists "uv")) {

    Write-Info "uv is not installed."
    Write-Info "Installing uv..."

    irm https://astral.sh/uv/install.ps1 | iex

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
        throw "uv was installed but is not available in PATH. Restart PowerShell and run the script again."
    }

    Write-Success "uv installed."
}

# ============================================================
# Stage 3
# Global AI tools
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 2 - Global AI Tools"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# Serena
# ------------------------------------------------------------

if ((Test-CommandExists "serena") -and -not $Force) {

    Write-Success "Serena already installed."

}
else {

    Write-Info "Installing Serena..."

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

if ((Test-CommandExists "graphify") -and -not $Force) {

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

if ((Test-CommandExists "codegraph") -and -not $Force) {

    Write-Success "CodeGraph already installed."

}
else {

    Write-Info "Installing CodeGraph..."

    Invoke-Expression `
        (Invoke-RestMethod `
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
Write-Host " Stage 3 - Graphify Integrations"
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
Write-Host " Stage 4 - Git Submodules"
Write-Host "============================================================"
Write-Host ""

Write-Info "Configuring OCP Excellence submodule..."

$GitModulesFile = Join-Path $ProjectPath ".gitmodules"
$SubmoduleFullPath = Join-Path $ProjectPath $DevStandardsPath

# ------------------------------------------------------------
# Ensure external directory exists
# ------------------------------------------------------------

$ExternalDirectory = Join-Path $ProjectPath "external"

if (-not (Test-Path $ExternalDirectory)) {

    Write-Info "Creating external directory..."

    New-Item `
        -ItemType Directory `
        -Path $ExternalDirectory `
        -Force |
        Out-Null
}

# ------------------------------------------------------------
# Handle existing submodule configuration
# ------------------------------------------------------------

$SubmoduleConfigured = $false

if (Test-Path $GitModulesFile) {

    $GitModulesContent = Get-Content `
        $GitModulesFile `
        -Raw `
        -ErrorAction SilentlyContinue

    if ($GitModulesContent -match [regex]::Escape($DevStandardsPath)) {
        $SubmoduleConfigured = $true
    }
}

# ------------------------------------------------------------
# Add submodule
# ------------------------------------------------------------

if ($SubmoduleConfigured) {

    Write-Success "OCP Excellence submodule already configured."

    if ($Force) {

        Write-Info "Updating existing OCP Excellence submodule..."

        Invoke-ExternalCommand `
            -Command "git" `
            -Arguments @(
                "submodule",
                "update",
                "--init",
                "--recursive",
                $DevStandardsPath
            )

    }

}
else {

    if (Test-Path $SubmoduleFullPath) {

        Write-WarningMessage `
            "Directory exists but is not configured as a Git submodule: $DevStandardsPath"

        if ($Force) {

            Write-Info "Removing existing directory because Force mode is enabled..."

            Remove-Item `
                -Recurse `
                -Force `
                $SubmoduleFullPath
        }
        else {

            throw @"
The directory already exists:

$SubmoduleFullPath

but it is not configured as a Git submodule.

Run the bootstrap with:

    .\setup.ps1 -Force
"@
        }
    }

    Write-Info "Adding OCP Excellence submodule..."

    Invoke-ExternalCommand `
        -Command "git" `
        -Arguments @(
            "submodule",
            "add",
            $DevStandardsRepository,
            $DevStandardsPath
        )

    Write-Success "OCP Excellence submodule added."
}

# ------------------------------------------------------------
# Validate submodule
# ------------------------------------------------------------

if (Test-Path $GitModulesFile) {

    Write-Success ".gitmodules created/configured."

}
else {

    throw ".gitmodules was not created."
}

if (Test-Path $SubmoduleFullPath) {

    Write-Success "OCP Excellence submodule available."

}
else {

    throw "OCP Excellence submodule directory was not created."
}

# ============================================================
# Stage 5
# OCP Excellence -> Kiro Steering Files
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 5 - OCP Excellence Steering Files"
Write-Host "============================================================"
Write-Host ""

$OcpExcellenceRepository = `
    $DevStandardsRepository

$OcpExcellencePath = `
    $SubmoduleFullPath

$KiroDirectory = `
    Join-Path $ProjectPath ".kiro"

$KiroSteeringDirectory = `
    Join-Path $KiroDirectory "steering"

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

    Write-Info "Creating .kiro/steering directory..."

    New-Item `
        -ItemType Directory `
        -Path $KiroSteeringDirectory `
        -Force |
        Out-Null
}

# ------------------------------------------------------------
# Locate steering files
# ------------------------------------------------------------

Write-Info "Searching OCP Excellence for Kiro steering files..."

$SteeringSources = @()

$PotentialSteeringDirectories = @(
    (Join-Path $OcpExcellencePath ".kiro\steering"),
    (Join-Path $OcpExcellencePath "steering"),
    (Join-Path $OcpExcellencePath "docs\steering")
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

    Write-WarningMessage `
        "Repository available at:"

    Write-Host "  $OcpExcellencePath"

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
            "Steering files copied to .kiro/steering"
    }
}

# ------------------------------------------------------------
# List installed steering files
# ------------------------------------------------------------

if (Test-Path $KiroSteeringDirectory) {

    Write-Info "Installed Kiro steering files:"

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

Write-Success "OCP Excellence steering setup completed."

# ============================================================
# Stage 6
# Serena project
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 6 - Serena Project"
Write-Host "============================================================"
Write-Host ""

Write-Info "Initializing Serena project: $ProjectName"

$SerenaDirectory = Join-Path $ProjectPath ".serena"
$SerenaProjectFile = Join-Path $SerenaDirectory "project.yml"

# ------------------------------------------------------------
# Validate existing Serena project
# ------------------------------------------------------------

if (Test-Path $SerenaProjectFile) {

    Write-Info "Existing Serena project found:"
    Write-Host "  $SerenaProjectFile"

    $SerenaConfig = Get-Content `
        $SerenaProjectFile `
        -Raw

    if ($SerenaConfig -notmatch "(?m)^languages\s*:") {

        Write-WarningMessage `
            "Serena project.yml is missing the required 'languages' property."

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

The configuration does not contain the required 'languages' property.

Run the bootstrap again using:

    .\setup.ps1 -Force
"@
        }
    }
}

# ------------------------------------------------------------
# Create Serena project
# ------------------------------------------------------------

if (-not (Test-Path $SerenaProjectFile)) {

    Write-Info "Creating Serena project..."

    try {

        Invoke-ExternalCommand `
            -Command "serena" `
            -Arguments @(
                "project",
                "create",
                "--name",
                $ProjectName
            )

        Write-Success "Serena project created."

    }
    catch {

        Write-WarningMessage `
            "Serena project create failed."

        Write-WarningMessage `
            "Serena may require a project configuration with languages."

        throw
    }

}
else {

    Write-Success "Serena project already exists."
}

# ------------------------------------------------------------
# Validate Serena project configuration
# ------------------------------------------------------------

if (-not (Test-Path $SerenaProjectFile)) {

    throw "Serena project.yml was not created: $SerenaProjectFile"
}

$SerenaConfig = Get-Content `
    $SerenaProjectFile `
    -Raw

if ($SerenaConfig -notmatch "(?m)^languages\s*:") {

    throw @"
Serena project.yml was created but does not contain 'languages'.

File:
$SerenaProjectFile

Please configure the project manually before indexing.
"@
}

Write-Success "Serena project configuration validated."

# ------------------------------------------------------------
# Index Serena project
# ------------------------------------------------------------

Write-Info "Indexing Serena project..."

Invoke-ExternalCommand `
    -Command "serena" `
    -Arguments @(
        "project",
        "index"
    )

Write-Success "Serena project indexed successfully."

# ============================================================
# Serena global initialization
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Serena Global Configuration"
Write-Host "============================================================"
Write-Host ""

$SerenaGlobalConfig = Join-Path `
    $env:USERPROFILE `
    ".serena\serena_config.yml"

if (-not (Test-Path $SerenaGlobalConfig)) {

    Write-Info "Initializing Serena global configuration..."

    try {

        Invoke-ExternalCommand `
            -Command "serena" `
            -Arguments @("init")

        Write-Success `
            "Serena global configuration initialized."

    }
    catch {

        Write-WarningMessage `
            "Serena global initialization failed."

        Write-WarningMessage `
            "The project configuration is already initialized."

        Write-WarningMessage `
            "You may need to run 'serena init' manually after reviewing the Serena configuration."
    }

}
else {

    Write-Success `
        "Serena global configuration already exists."
}

# ============================================================
# Stage 7
# CodeGraph initialization
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 7 - CodeGraph"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path ".codegraph") -or $Force) {

    Write-Info "Initializing CodeGraph..."

    Invoke-ExternalCommand `
        -Command "codegraph" `
        -Arguments @(
            "init",
            "-i"
        )

    Write-Success "CodeGraph initialized."

}
else {

    Write-Success "CodeGraph already initialized."
}

# ============================================================
# Stage 8
# Graphify project
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 8 - Graphify Project"
Write-Host "============================================================"
Write-Host ""

Write-Info "Running Graphify..."

try {

    Invoke-ExternalCommand `
        -Command "graphify" `
        -Arguments @(".")

    Write-Success "Graphify extraction completed."

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

Write-Info "Installing Graphify hook..."

try {

    Invoke-ExternalCommand `
        -Command "graphify" `
        -Arguments @(
            "hook",
            "install"
        )

    Write-Success "Graphify hook installed."

}
catch {

    Write-WarningMessage `
        "Graphify hook installation failed."
}

# ============================================================
# Stage 9
# OpenSpec
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 9 - OpenSpec"
Write-Host "============================================================"
Write-Host ""

if (-not (Test-Path "openspec") -or $Force) {

    Write-Info "Initializing OpenSpec for Kiro..."

    Invoke-ExternalCommand `
        -Command "openspec" `
        -Arguments @(
            "init",
            "--tools",
            "kiro"
        )

    Write-Success "OpenSpec initialized."

}
else {

    Write-Success "OpenSpec already initialized."
}

# ============================================================
# Stage 10
# APM
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 10 - APM"
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

    throw "APM command not found."
}

Write-Success "APM detected."

# ------------------------------------------------------------
# Install APM components for Kiro
# ------------------------------------------------------------

Write-Info "Installing APM package for Kiro..."

Invoke-ExternalCommand `
    -Command "apm" `
    -Arguments @(
        "install",
        "--target",
        "kiro"
    )

Write-Success "APM components installed."

# ============================================================
# Stage 11
# OpenSpec update
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Stage 11 - OpenSpec Update"
Write-Host "============================================================"
Write-Host ""

Write-Info "Updating OpenSpec..."

Invoke-ExternalCommand `
    -Command "openspec" `
    -Arguments @("update")

Write-Success "OpenSpec updated."

# ============================================================
# Stage 12
# Final verification
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host " Final Verification"
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

                "serena" {
                    "installed"
                }

                "graphify" {
                    "installed"
                }

                "codeburn" {
                    "installed"
                }

                "openspec" {
                    "installed"
                }

                "openspecui" {
                    "installed"
                }

                "codegraph" {
                    "installed"
                }

                "apm" {
                    "installed"
                }
            }

            Write-Success "$Tool : $Version"

        }
        catch {

            Write-Success "$Tool : installed"
        }

    }
    else {

        Write-WarningMessage "$Tool : NOT FOUND"
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
    "external/ocp-excellence"
)

foreach ($Artifact in $Artifacts) {

    if (Test-Path $Artifact) {

        Write-Success $Artifact

    }
    else {

        Write-WarningMessage "$Artifact not found."
    }
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

Write-Host "Git:"
Write-Host "  OCP Excellence submodule"
Write-Host "  external/ocp-excellence"

Write-Host ""

Write-Host "Log:"
Write-Host "  $LogFile"

Write-Host ""

Write-Host "Recommended next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Review:"
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
Write-Host "This command is interactive and therefore is intentionally not"
Write-Host "automatically configured by this bootstrap script."
Write-Host ""

Write-Host "After selecting the desired profile, run:"
Write-Host ""

Write-Host "    openspec update" -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""

Stop-Transcript | Out-Null