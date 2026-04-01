# -----------------------------------------------------------------------------
# Script: Refresh-SSHCredentials.ps1
# Purpose: Automated Step CA signing & SSH-agent injection
# Logic: Single-entry password, Multi-target execution, SOLID structure
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# --- 1. Configuration (The "System" Setup) ---
# Decoupling data from logic. Add new targets here.
$CertTargets = @(
    @{
        Identity    = "luist@192.168.1.250"
        KeyPath     = "$HOME\.ssh\id_ecdsa"
        Provisioner = $null
    },
    @{
        Identity    = "geltdro@geltdro.docker.local"
        KeyPath     = "$HOME\.ssh\id_tool"
        Provisioner = "admin"
    }
)

# --- 2. Core Functions ---

function Invoke-StepSigning {
    param (
        [Parameter(Mandatory=$true)] [string]$Password,
        [Parameter(Mandatory=$true)] [HashTable]$Target
    )

    Write-Host "-> Signing: $($Target.Identity)" -ForegroundColor Cyan
    
    # Base command construction
    $cmd = "step ssh certificate $($Target.Identity) $($Target.KeyPath) --password-file=-"
    if ($Target.Provisioner) {
        $cmd += " --provisioner $($Target.Provisioner)"
    }

    # Execute signing via stdin pipe
    $Password | iex $cmd

    # Feature: Add to SSH Agent
    if ($LASTEXITCODE -eq 0) {
        ssh-add $Target.KeyPath
        Write-Host "   [Success] Signed and added to agent." -ForegroundColor Green
    }
}

# --- 3. Main Execution Flow ---

function Main {
    # Ensure ssh-agent is running in Windows
    if (!(Get-Service ssh-agent | Where-Object { $_.Status -eq 'Running' })) {
        Write-Host "Starting SSH Agent..." -ForegroundColor Yellow
        Start-Service ssh-agent
    }

    # Single point of entry for password (Energy Management)
    $securePass = Read-Host "Master Step Password" -AsSecureString
    $passPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
    $plainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($passPtr)

    try {
        foreach ($target in $CertTargets) {
            Invoke-StepSigning -Password $plainPass -Target $target
        }
    }
    finally {
        # Security: Wipe plain text from memory immediately
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passPtr)
        $plainPass = $null
        Write-Host "Memory cleared. Session secure." -ForegroundColor Gray
    }
}

# Run it
Main