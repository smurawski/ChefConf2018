# Setting up your workstation

*in a cross-platform friendly way*

## Install the basic tools

* Open a PowerShell session as an administrator
* Check our ExecutionPolicy (looking for `Bypass`, `RemoteSigned`, or `Unrestricted`)
* In the PowerShell session:

```
Get-ExecutionPolicy
Get-ExecutionPolicy -List

Set-ExecutionPolicy RemoteSigned
```

### Install Chocolatey

* In the PowerShell session:

```
invoke-expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

### Use Chocolatey to install ChefDk

* In the PowerShell session:

```
choco install chefdk --version 1.2.22
```

### Use Chocolatey to install VS Code

```
choco install visualstudiocode
```

* Close the PowerShell session

## Setup working environment

* Make ChefDK our primary environment

```
chef shell-init powershell | invoke-expression
```

### Setup Git

* Open a PowerShell session as an administrator
* In the PowerShell session:

```
# Use the Windows Credential Store to save your git password
# This is actually the default setting on Windows now
git config --global credential.helper wincred

# Set your email address
git config --global user.email "you@your_provider.com"

# Set your name
git config --global user.name "FirstName LastName"

# Set VS Code as the editor
git config --global core.editor "code --wait"

# Set VS Code as the difftool
git config --global difftool.default-difftool.cmd 'code --wait --diff $LOCAL $REMOTE'
git config --global diff.tool "default-difftool"

# Make git cross-platform friendly 
# especially for docker and vagrant which may mount your windows files

# checkout files with a unix line ending 
git config --global core.eol "lf"

# make sure files we create end up with a unix line ending in a pushed branch
git config --global core.autocrlf "input"
```

### Setup Our Editor

### Install some handy extensions

* In the PowerShell session:

```
code --install-extension ms-vscode.PowerShell
code --install-extension rebornix.Ruby
code --install-extension Pendrica.Chef
```

* Close the PowerShell session

### Set some platform agnostic settings

* Open VS Code
* Control + , (shortcut to open user settings)
* Edit user settings

```
{
    "files.eol": "\n",
    "editor.trimAutoWhitespace": true
}
```