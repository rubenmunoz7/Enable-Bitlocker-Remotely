# Author: Ruben Munoz
# Script to enable BitLocker through powershell. 
# Credits for instructions go to Peter Bretton, VP, Product Strategy @ NinjaOne https://www.ninjaone.com/blog/how-to-remotely-manage-bitlocker-encryption-powershell-ninjarmm/
# Initializes TPM if needed, and enables bitlocker on C: drive
# Prints markers for the output, and extracts recovery keys

$os = $env:SystemDrive
Write-Host "NINJA_BITLOCKER: START"     # Marker for N1 log

try {
    $v = Get-BitLockerVolume -MountPoint $os # Grab current Bitlocker state from the OS drive    

}

    # Exit is it is already encrypted
    if ($v -and $v.ProtectionStatus -eq 1){
        Write-Host "NINJA_BITLOCKER: ALREADY ENCRYPTED" # Output log
        exit 0
    }

    # Check TPM status 
    # IF a TPM exists, but isn't ready, then initialize if needed using "Initialize-tpm"
    $tpm = Get-Tpm -ErrorAction SilentlyContinue
    $tpmReady = $false
    if ($tpm -and $tpm.TpmPresent) {
        if (-not $tpm.TpmReady) {
            Initialize-Tpm -ErrorAction SilentlyContinue | Out-Null
            Start-Sleep 2
        }
        # Retry TPM state after initialization attempt
        $tpm = Get-Tpm -ErrorAction SilentlyContinue
        $tpmReady = ($tpm -and $tpm.TpmReady)
    }
    Write-Host "NINJA_BITLOCKER: TPM_READY=$tpmReady" # Output

    if (-not $tpmReady) {
        Write-Error "NINJA_BITLOCKER: TPM not present/ready"
        exit 2 # alert
    }

    # enable with TPM protector
    Write-Host "NINJA_BLOCKER: ENABLE_ATTEMPT (TPMProtector)"
    Enable-BitLocker -MountPoint $os -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector

    Start-Sleep 2
    $post = Get-BitlockerVolume -mountPoint $os
    Write-Host "NINJA_BITLOCKER: STATUS=$($post.ProtectionStatus)" # 1 = On
    Write-Host "NINJA_BITLOCKER: ENABLED_OK"
    exit 0
}
catch {
    Write-Error ("NINJA_BITLOCKER: ERROR " + $ .Exception.Message)
    exit 1
}
