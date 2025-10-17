<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://i.imgur.com/s1wF4HP.png" alt="Project logo"></a>
</p>

<h3 align="center">🔐 PowerShell script to enable BitLocker remotely via NinjaOne</h3>

<div align="center">

</div>

---

<p align="center"> 
 
<br> 
</p>

## 📝 Table of Contents
- [About](#about)
- [Usage](#usage)
- [Built Using](#built_using)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

---

## 🧐 About <a name = "about"></a>
This project automates BitLocker drive encryption through a PowerShell script that can be deployed either locally or via NinjaOne. It follows the NinjaOne guide written by *Peter Bretton (VP of Product Strategy @ NinjaOne)* and enables BitLocker on the System OS drive using the computer's TPM, or Trusted Platform Module. This PowerShell script checks if BitLocker is already active, verifies the TPM, initializes the TPM if needed, then enables BitLocker with XTS-AES encryption, just like it is shown in the NinjaOne Blog by Peter Bretton. 

---

## 🎈 Usage <a name="usage"></a>

To use the automation script:
1. Set the automation script to run as SYSTEM in N1.
2. Monitor the results through the N1 Output Monitor
3. Output meaning:
  **NINJA_BITLOCKER: START**
   
     - The script launched/ran
       
   **NINJA_BITLOCKER: ALREADY_ENCRYPTED**

     - The OS drive is already encrypted, *exit 0*
       
   **NINJA_BITLOCKER: TPM_READY=True**

     - The device has a TPM and is ready to use, the script will now enable BitLocker
       
   **NINJA_BITLOCKER: TPM_READY=False**

     - TPM missing/disabled
       
   **NINJA_BITLOCKER: ENABLE_ATTEMPT (TPMProtector)**

     - Script is calling TPM protector
       
   **NINJA_BITLOCKER: STATUS=1**

     - ProtectionStatus=On means BitLocker was successfully enabled
       
   **NINJA_BITLOCKER: ENABLED_OK**

     - Completed with no errors
       
   **NINJA_BITLOCKER: ERROR:**

     - Exit code 1 when there is an error

--
✅ Successful run example output: 
NINJA_BITLOCKER: START
NINJA_BITLOCKER: TPM_READY=True
NINJA_BITLOCKER: ENABLE_ATTEMPT (TPMProtector)
NINJA_BITLOCKER: STATUS=1
NINJA_BITLOCKER: ENABLED_OK

---

## ⛏️ Built Using <a name = "built_using"></a>
- [PowerShell](https://learn.microsoft.com/en-us/powershell/) – Automation scripting
- [BitLocker](https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/)

---

## ✍️ Authors <a name = "authors"></a>
- [@RubenMunoz](https://github.com/rubenmunoz7) – Developer & Maintainer  
---

## ⭐ Acknowledgements <a name = "acknowledgement"></a>
- **Peter Bretton** - VP of Product Strategy @ NinjaOne (original guide and command examples)
- **NinjaOne Blog** - (https://www.ninjaone.com/blog/how-to-remotely-manage-bitlocker-encryption-powershell-ninjarmm/)
- **Microsoft Docs** for official PowerShell and BitLocker references
