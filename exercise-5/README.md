# Running PowerShell as another user

## Getting setup

* Open a PowerShell session as an administrator
* In the PowerShell session:

```
chef shell-init powershell | iex
cd ~/chefconf2017/mwwfy
chef generate attribute . local
```

* In the editor, open ./attributes/local.rb
* Add

```
default['mwwfy']['alternate_user'] = 'ChefPowerShell2'
default['mwwfy']['alternate_password'] = 'P2ssw0rd!'
```

## Run commands as another user

* In the editor, open .kitchen.local.yml 
* Update the transport to:

```
transport:
  name: winrm
  username: 'ChefPowerShell'
  password: 'P2ssw0rd!'
  elevated: true
  elevated_username: SYSTEM
  elevated_password: ''
```


### Create our alternate user
* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
user node['mwwfy']['alternate_user']  do
  comment 'another'
  password node['mwwfy']['alternate_password']
  action :create
end
```

* In the PowerShell session:

```
kitchen converge
```

### Using Mixlib::Shellout

* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
puts "Alternate User from Mixlib::Shellout"
puts (Mixlib::ShellOut.new('whoami.exe', 
  :user => node['mwwfy']['alternate_user'], 
  :password => node['mwwfy']['alternate_password'])).run_command.stdout
```

* In the PowerShell session:

```
kitchen converge
```

### Using powershell_out

*THIS IS CURRENTLY BROKEN*

* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
puts "Alternate User from powershell_out"
puts (powershell_out('whoami.exe', 
  :user => node['mwwfy']['alternate_user'], 
  :password => node['mwwfy']['alternate_password'])).stdout
```

* In the PowerShell session:

```
kitchen converge
```

### Using the execute resource

* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
directory 'c:\ChefDemo'

execute 'CMD as another user' do
  user node['mwwfy']['alternate_user']
  password node['mwwfy']['alternate_password']
  command <<-EOH
    whoami > c:\\ChefDemo\\execute_alternate_creds.txt
  EOH
end

ruby_block 'Read the name for execute as another user' do
  block do
    puts ""
    puts File.read("c:\\ChefDemo\\execute_alternate_creds.txt")
    puts ""
  end
  action :run
end
```

* In the PowerShell session:

```
kitchen converge
```

### Using the powershell_script resource

*THIS IS CURRENTLY BROKEN*

* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
powershell_script 'PS as another user' do
  user node['mwwfy']['alternate_user']
  password node['mwwfy']['alternate_password']
  code <<-EOH
    whoami | out-file 'c:/ChefDemo/powershell_script_alternate_creds.txt'
  EOH
end

ruby_block 'Read the name for powershell_script as another user' do
  block do
    puts ""
    puts File.read("c:\\ChefDemo\\powershell_script_alternate_creds.txt")
    puts ""
  end
  action :run
end
```

* In the PowerShell session:

```
kitchen converge
```

## Passing credentials into a powershell_script

*THIS IS BROKEN, BUT COULD WORK IF I HAD A REMOTE SYSTEM TO TARGET*

* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
require 'chef/dsl/powershell'
cred = ps_credential(node['mwwfy']['alternate_user'], node['mwwfy']['alternate_password'])

powershell_script 'PS as another user' do
  code <<-EOH
    get-wmiobject chefconf-0.centralus.cloudapp.azure.com win32_computersystem -credential (#{cred.to_s.chomp})
  EOH
end
```

* In the PowerShell session:

```
kitchen converge
```

## Running dsc_resource as another user

* In the editor, open ./recipes/default.rb
* Add to the bottom of the recipe

```
dsc_resource 'DSC as another user' do
  resource :script
  property :GetScript, '@{}'
  property :TestScript, '$false'
  property :SetScript, 'whoami | out-file c:/ChefDemo/dsc_resource_alternate_creds.txt'
  property :psdscrunascredential, cred
end

ruby_block 'Read the name for dsc_resource as another user' do
  block do
    puts ""
    puts File.read("c:\\ChefDemo\\dsc_resource_alternate_creds.txt")
    puts ""
  end
  action :run
end
```

* In the PowerShell session:

```
kitchen converge
```
