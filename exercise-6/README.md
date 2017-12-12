# Tricky Bits

## Connecting to a Chef Server with a self-signed or internal cert

* Copy the chef-repo directory from the cloned repository to `~/chefconf2017/`

* Open a PowerShell session as an administrator
* In the PowerShell session:

```
chef shell-init powershell | iex
cd ~/chefconf2017/chef-repo
knife client list # should fail
```

* Then, in the Powershell session:

```
knife ssl fetch
knife client list
```

### Add that certificate to the local machine store

* Open certmgr.mmc
* Right click on the Personal store for the local machine
* Select All Tasks
* Select Import
* Browse to `~/chefconf2017/chef-repo/.chef/trusted_certs`
* Select `chefmurawski_southcentralus_cloudapp_azure_com.crt`

* OR

* Use the `windows_certificate` resource in the `windows` cookbook

## Bootstrap your node to the Chef Server

* In the PowerShell session:

```
knife bootstrap windows winrm chefconf-{YOUR NUMBER HERE}.southcentralus.cloudapp.azure.com -x ChefPowerShell -P P2ssw0rd! -N chefconf-{YOUR NUMBER HERE}
```