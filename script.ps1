function Generate-RandomPassword {
    param (
        [int]$minLength = 10,
        [int]$maxLength = 20
    )

    $length = Get-Random -Minimum $minLength -Maximum $maxLength
    $password = -join ((33..126) | ForEach-Object { [char]$_ } | Get-Random -Count $length)
    return $password
}

function EncryptText {
    param (
        [string]$password,
        [string]$text
    )

    # Generate a key by hashing the password
    $algo = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($password)
    $Key = $algo.ComputeHash($bytes)

    # Encrypt the text
    $SecStr = ConvertTo-SecureString -String $text -AsPlainText -Force
    $EncStr = $SecStr | ConvertFrom-SecureString -Key $Key
    return $EncStr
}

function Decrypt-Text {
    param (
        [string]$password,
        [string]$encryptedText
    )
   
    # Generate a key by hashing the password
    $algo = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($password)
    $StrB = [System.Text.StringBuilder]::new()
    $algo.ComputeHash($bytes) | foreach { [void]$StrB.Append($_.ToString('x2')) }
    $Key = [byte[]][char[]]($StrB.ToString(0, 32))

    # Decrypt the text
    $SecStr = $encryptedText | ConvertTo-SecureString -Key $Key
    $BinStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecStr)
    $Text = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BinStr)
    return $Text
}

function Encrypt-File {
    param (
        [string]$password,
        [string]$filePath
    )

    # Generate a key by hashing the password
    $algo = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($password)
    $StrB = [System.Text.StringBuilder]::new()
    $algo.ComputeHash($bytes) | foreach { [void]$StrB.Append($_.ToString('x2')) }
    $Key = [byte[]][char[]]($StrB.ToString(0, 32))

    # Encrypt the file
    $Text = Get-Content $filePath -Raw
    $SecStr = ConvertTo-SecureString -String $Text -AsPlainText -Force
    $EncStr = $SecStr | ConvertFrom-SecureString -Key $Key
    $EncStr | Out-File $filePath -Encoding utf8 -NoNewline
    Write-Host "The file has been successfully encrypted."
}

function Decrypt-File {
    param (
        [string]$password,
        [string]$filePath
    )

    # Generate a key by hashing the password
    $algo = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($password)
    $StrB = [System.Text.StringBuilder]::new()
    $algo.ComputeHash($bytes) | foreach { [void]$StrB.Append($_.ToString('x2')) }
    $Key = [byte[]][char[]]($StrB.ToString(0, 32))

    # Decrypt the file
    $EncStr = Get-Content $filePath -Raw -Encoding UTF8
    $SecStr = $EncStr | ConvertTo-SecureString -Key $Key
    $BinStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecStr)
    $Text = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BinStr)
    $Text | Out-File $filePath -Encoding utf8 -NoNewline
    Write-Host "The file has been successfully decrypted."
}       

function Process-Folder {
    param (
        [string]$password,
        [string]$folderPath,
        [switch]$encrypt
    )

    $files = Get-ChildItem -Path $folderPath -File -Recurse
    foreach ($file in $files) {
        if ($encrypt) {
            Encrypt-File -password $password -filePath $file.FullName
        }
        else {
            Decrypt-File -password $password -filePath $file.FullName
        }
    }
    if ($encrypt) {
        Write-Host "All files in the folder have been encrypted."
    }
    else {
        Write-Host "All files in the folder have been decrypted."
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "`n--------------------- SecureFileEncryptor ---------------------`n" -ForegroundColor Cyan
    Write-Host "Select an option:" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------" 
    Write-Host "  1: Encrypt Text         `t`  2: Decrypt Text"
    Write-Host "----------------------------------------------------------"  
    Write-Host "  3: Encrypt File         `t`  4: Decrypt File"
    Write-Host "----------------------------------------------------------"  
    Write-Host "  5: Process Folder"
    Write-Host "----------------------------------------------------------"  
    Write-Host "  6: Exit`n"
    Write-Host "----------------------------------------------------------" 
}

function ValidateInput {
    param (
        [string]$_input,
        [string]$message
    )
    if ([string]::IsNullOrWhiteSpace($_input)) {
        Write-Host "$message" -ForegroundColor Red
        return $false
    }
    return $true
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        '1' {
            $password = Read-Host "Enter password (pesss enter to auto-generate)"
            if (-not $password) {
                $password = Generate-RandomPassword
                Write-Host "Auto-generated Password: $password`n" -ForegroundColor Yellow
                Start-Sleep 1
            }

            $text = Read-Host "Enter text to encrypt"
            if (-not (ValidateInput -_input $text -message "Text cannot be empty.")) { continue }
            $encryptedText = EncryptText -password $password -text $text
            Write-Host "Encrypted Text: $encryptedText`n" -ForegroundColor Green
        }
        '2' {
            $password = Read-Host "Enter password"
            if (-not (ValidateInput -_input $password -message "password cannot be empty.")) { continue }
            $encryptedText = Read-Host "Enter text to decrypt"
            if (-not (ValidateInput -_input $encryptedText -message "Encrypted text cannot be empty.")) { continue }
            $decryptedText = Decrypt-Text -password $password -encryptedText $encryptedText
            Write-Host "Decrypted Text: $decryptedText`n" -ForegroundColor Green
        }
        '3' {
            $password = Read-Host "Enter password (pesss enter to auto-generate)"
            if (-not $password) {
                $password = Generate-RandomPassword
                Write-Host "Auto-generated Password: $password`n" -ForegroundColor Yellow
                Start-Sleep 1
            }

            if (-not (ValidateInput -_input $password -message "Password cannot be empty.")) { continue }
            $filePath = Read-Host "Enter input file path"
            if (-not (ValidateInput -_input $filePath -message "File path cannot be empty.")) { continue }
            try {
                Encrypt-File -password $password -filePath $filePath
                Write-Host "File encrypted successfully.`n" -ForegroundColor Green
            }
            catch {
                Write-Host "Error encrypting file: $_`n" -ForegroundColor Red
            }
        }
        '4' {
            $password = Read-Host "Enter password"
            if (-not (ValidateInput -_input $password -message "password cannot be empty.")) { continue }
            if (-not (ValidateInput -_input $password -message "Password cannot be empty.")) { continue }
            $filePath = Read-Host "Enter input file path"
            if (-not (ValidateInput -_input $filePath -message "File path cannot be empty.")) { continue }
            try {
                Decrypt-File -password $password -filePath $filePath
                Write-Host "File decrypted successfully.`n" -ForegroundColor Green
            }
            catch {
                Write-Host "Error decrypting file: $_`n" -ForegroundColor Red
            }
        }
        '5' {
            $password = Read-Host "Enter password (pesss enter to auto-generate)"
            if (-not $password) {
                $password = Generate-RandomPassword
                Write-Host "Auto-generated Password: $password`n" -ForegroundColor Yellow
                Start-Sleep 1
            }

            if (-not (ValidateInput -_input $password -message "Password cannot be empty.")) { continue }
            $folderPath = Read-Host "Enter folder path"
            if (-not (ValidateInput -_input $folderPath -message "Folder path cannot be empty.")) { continue }

            Write-Host "`nChoose an action for all files in the folder:`n" -ForegroundColor Cyan
            Write-Host "1: Encrypt all files"
            Write-Host "2: Decrypt all files`n"
            $folderChoice = Read-Host "Enter your choice"

            switch ($folderChoice) {
                '1' {
                    try {
                        Process-Folder -password $password -folderPath $folderPath -encrypt
                        Write-Host "All files encrypted successfully.`n" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Error encrypting files in folder: $_`n" -ForegroundColor Red
                    }
                }
                '2' {
                    try {
                        Process-Folder -password $password -folderPath $folderPath -encrypt:$false
                        Write-Host "All files decrypted successfully.`n" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Error decrypting files in folder: $_`n" -ForegroundColor Red
                    }
                }
                default {
                    Write-Host "Invalid action. Please specify 'encrypt' or 'decrypt'." -ForegroundColor Red
                }
            }
        }
        '6' {
            Write-Host "Exiting. Thank you for using SecureFileEncryptor!" -ForegroundColor Cyan
        }
        default {
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
        }
    }
    Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
    [void][System.Console]::ReadKey($true)

} while ($choice -ne '6')
