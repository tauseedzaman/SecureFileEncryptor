﻿# SecureFileEncryptor
![image](https://github.com/user-attachments/assets/497a4f62-66e6-4d1a-9ddb-745739ad864d)

SecureFileEncryptor is a PowerShell tool for securely encrypting and decrypting text, files, and folders using password-protected SHA-256 hashing. The tool provides a simple interactive menu, allowing users to perform encryption and decryption operations on individual texts, files, or entire directories.

## Features

- **Text Encryption/Decryption**: Encrypts plain text to a secure, hashed format, and decrypts it back to the original text.
- **File Encryption/Decryption**: Encrypts text content within files and saves it in the same file securely.
- **Folder Encryption/Decryption**: Processes all files within a folder for batch encryption or decryption.
- **SHA-256 Password Hashing**: Uses a SHA-256 hash of your password as the key, adding an extra layer of security.

## Prerequisites

- **PowerShell**: Ensure PowerShell is installed on your system (version 5.1 or later recommended).

## Usage

1. **Download and open the script** in PowerShell.
2. **Run** the script: `.\SecureFileEncryptor.ps1`
3. **Choose an option** from the menu:
    - **1**: Encrypt Text
    - **2**: Decrypt Text
    - **3**: Encrypt File
    - **4**: Decrypt File
    - **5**: Process Folder (Encrypt or Decrypt all files in a folder)
    - **6**: Exit the application

## Example Usage

```powershell
.\SecureFileEncryptor.ps1
```

### Encrypting a Text String

1. Select `1` to Encrypt Text.
2. Enter a password.
3. Input the text you want to encrypt.
4. The tool displays the encrypted text.

### Decrypting a File

1. Select `4` to Decrypt a File.
2. Enter the same password used for encryption.
3. Provide the path to the encrypted file.
4. The decrypted content will replace the encrypted content in the file.

## Security Notes

- **Password Matching**: Ensure you use the same password for encryption and decryption.
- **Data Security**: Encrypted files and text should be handled carefully, as they will be overwritten in place.

## License

This project is licensed under the MIT License.
