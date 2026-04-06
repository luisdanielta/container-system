# -----------------------------------------------------------------------------
# Script: Refresh-SSHCredentials.ps1
# Logic: Total Silence Wrapper for noisy CLI tools (step, ssh-add)
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:STEP_LOGGER_LEVEL = "error"

# --- 1. Configuration ---
$CertTargets = @(
    @{ Identity = "luist@192.168.1.250"; KeyPath = "$HOME\.ssh\id_ecdsa"; Provisioner = "admin" },
    @{ Identity = "geltdro@geltdro.docker.local"; KeyPath = "$HOME\.ssh\id_tool"; Provisioner = "admin" }
)

# --- 2. Helper: The Silencer ---
# Esta función ejecuta un comando y evita que PowerShell entre en pánico por stderr
function Invoke-SilentBinary {
    param ([ScriptBlock]$Code)
    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        & $Code 2>$null | Out-Null
    } finally {
        $ErrorActionPreference = $oldEAP
    }
}

# --- 3. Core Function ---
function Invoke-StepSigning {
    param (
        [Parameter(Mandatory=$true)] [string]$Password,
        [Parameter(Mandatory=$true)] [HashTable]$Target
    )

    Write-Host "-> Signing: $($Target.Identity)" -ForegroundColor Cyan
    
    $identity = $Target.Identity
    $keyPath  = $Target.KeyPath
    $prov     = if ($Target.Provisioner) { "--provisioner $($Target.Provisioner)" } else { "" }

    # Paso 1: Firmar el certificado (usando CMD para bypass total)
    Invoke-SilentBinary {
        $Password | cmd /c "step ssh certificate $identity `"$keyPath`" --password-file=- --force $prov 2>NUL"
    }

    # Paso 2: Validar y añadir al agente
    if ($LASTEXITCODE -eq 0 -and (Test-Path "$keyPath-cert.pub")) {
        # Aquí es donde fallaba antes: ssh-add es ruidoso
        Invoke-SilentBinary { & ssh-add $keyPath }
        Write-Host "   [Success] Signed and added to agent." -ForegroundColor Green
    } else {
        Write-Host "   [Error] Process failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Red
    }
}

# --- 4. Main ---
function Main {
    if (!(Get-Service ssh-agent | Where-Object { $_.Status -eq 'Running' })) {
        Start-Service ssh-agent
    }

    $securePass = Read-Host "Master Step Password" -AsSecureString
    if ($null -eq $securePass) { return }

    $passPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
    $plainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($passPtr)

    try {
        foreach ($target in $CertTargets) {
            Invoke-StepSigning -Password $plainPass -Target $target
        }
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passPtr)
        $plainPass = ""
        Write-Host "Memory cleared. Session secure." -ForegroundColor Gray
    }
}

Main