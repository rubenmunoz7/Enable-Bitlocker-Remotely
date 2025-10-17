# Author: Ruben Munoz
# Script to enable BitLocker through powershell. 
# Credits for instructions go to Peter Bretton, VP, Product Strategy @ NinjaOne https://www.ninjaone.com/blog/how-to-remotely-manage-bitlocker-encryption-powershell-ninjarmm/
# Initializes TPM if needed, and enables bitlocker on C: drive
# Prints markers for the output, and extracts recovery keys

$os = $env:SystemDrive
Write-Host "NINJA_BITLOCKER: START"     # Marker for N1 log

try {
    $v = Get-BitLockerVolume -MountPoint $os # Grab current Bitlocker state from the OS drive    

    # Output log if it is already encrypted
    if ($v -and $v.ProtectionStatus -eq 1){ # if drive is already encrypted
        Write-Host "NINJA_BITLOCKER: ALREADY_ENCRYPTED" # Output log
        exit 0
    }

    # Check TPM status 
    # IF a TPM exists, but isn't ready, then initialize if needed using "Initialize-tpm"
    $tpm = Get-Tpm -ErrorAction SilentlyContinue 
    $tpmReady = $false  # Default flag
    if ($tpm -and $tpm.TpmPresent) { # if tpm exists
        if (-not $tpm.TpmReady) { # If TPM is not ready, initialize it
            Initialize-Tpm -ErrorAction SilentlyContinue | Out-Null
            Start-Sleep 2 # pause for 2 seconds
        }
        # Retry TPM state after initialization attempt
        $tpm = Get-Tpm -ErrorAction SilentlyContinue    # Recheck TPM
        $tpmReady = ($tpm -and $tpm.TpmReady)           # Ready flag
    }
    Write-Host "NINJA_BITLOCKER: TPM_READY=$tpmReady" # Output

    if (-not $tpmReady) {
        Write-Error "NINJA_BITLOCKER: TPM not present/ready" # If TPM is not ready, stop
        exit 2 # error code
    }

    # enable with TPM protector
    Write-Host "NINJA_BITLOCKER: ENABLE_ATTEMPT (TPMProtector)"
    Enable-BitLocker -MountPoint $os -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector   # Enable Bitlocker on C: drive, uses XTS-AES 256-bit encryption

    Start-Sleep 2
    $post = Get-BitlockerVolume -mountPoint $os     # Check post-encrpytion
    Write-Host "NINJA_BITLOCKER: STATUS=$($post.ProtectionStatus)" # 1 = On
    Write-Host "NINJA_BITLOCKER: ENABLED_OK"     # Log success
    exit 0
}
catch {
    Write-Error ("NINJA_BITLOCKER: ERROR: " + $_.Exception.Message)         # Write any errors, then exit
    exit 1
}
