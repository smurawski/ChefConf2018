# Testing our Cheffing on Windows with Test-Kitchen

## Create a cookbook

* Open a PowerShell session as an administrator
* In the PowerShell session:

```
chef shell-init powershell | iex
```

### Create a working directory

* In the PowerShell session:

```
mkdir ~/chefconf2018
cd ~/chefconf2018
```

### Generate a cookbook to work with

* In the PowerShell session:

```
# mwwfy - Making Windows Work For You
chef generate cookbook mwwfy --copyright 'Steven Murawski' --email 'steven.murawski@microsoft.com' --license apachev2 --berks
cd mwwfy
```

## Setting up your test kitchen

* Copy the .kitchen.local.yml to your cookbook directory

```
cp ~/lab/chefconf2018/exercise-2/.kitchen.local.yml -destination .

```

* Open .kitchen.local.yml in your editor.

### Make sure Test-Kitchen can read our configuration files

* In the PowerShell session:

```
chef gem install kitchen-azurerm
kitchen list
```

### Validate that you can talk to your test machine

* In the PowerShell session:

```
kitchen create
```

## Adding resources to the recipe

* Open the default recipe ('default.rb') in your editor
* Add

```
file 'c:\hello.txt' do
  content 'Chef wrote me.'
  action :create
end
```

* Save 'default.rb'

### Converge

* In the PowerShell session:

```
kitchen converge
```

## Adding a Reboot to the recipe

* Open the default recipe
* Add (before the `file` resource)

```
reboot 'Restarting for fun and profit' do
  action :nothing
  reason 'Because I can'
  delay_mins 1
end
```

* Edit the `file` resource's content property
* Add a notifies property

```
file 'c:\hello.txt' do
  content "Chef's gonna reboot your server. Ha Ha."
  action :create
  notifies :reboot_now, 'reboot[Restarting for fun and profit]', :immediately
end
```

* Save 'default.rb'

## Verify

### Create our test

* In your editor, create a file 'default_spec.rb' in the `test\integration\default` folder
* Replace the existing tests with

```
describe file('c:\hello.txt') do
  its('content') { should match(%r{Chef's gonna reboot your server. Ha Ha.}) }
end
```

* Save 'default_spec.rb'

### Run the test

* In the PowerShell session:

```
kitchen verify
```

## Remediating one of our Baseline Compliance Failures

### Scan our machine for compliance against DevSec Windows Baseline

#### Get your machine details
* Open the kitchen file in your editor ('/.kitchen/default-windows-server-2016.yml')
* Grab the username / password / address

#### View the DevSec Windows Baseline
* https://github.com/dev-sec/windows-baseline

#### Scan your machine with the Baseline InSpec profile
* In the PowerShell session:

```
inspec exec https://github.com/dev-sec/windows-baseline -t winrm://[username]@[host] --password [password]
```
* Review your results and note the passes and failures on a base Windows 2016 VM


### Adding a registry key resource to our recipe
* In your editor open your default recipe ('default.rb')
* Add the following to the end of your recipe

```
registry_key "HKLM\\Software\\Policies\\Microsoft\\Internet Explorer\\Main" do
  values [{
    name: "Isolation64Bit",
    type: :dword,
    data: 1
  }]
  action :create
  recursive true
end
```

* Save 'default.rb'

### Write InSpec test to validate our change
* In your editor, open 'default_spec.rb' in the `test\integration\default` folder
* Add this test to the end of the file

```
  describe registry_key('HKLM\Software\Policies\Microsoft\Internet Explorer\Main') do
    it { should exist }
    its('Isolation64Bit') { should eq 1 }
  end
```

* Save 'default_spec.rb'

### Converge and verify our machine

* In the PowerShell session
```
kitchen converge
kitchen verify
```

### Re-run Compliance Scan to see passing control
* In the PowerShell session
```
inspec exec https://github.com/dev-sec/windows-baseline -t winrm://[username]@[host] --password [password]
```
* Note that the control `windows-ie-101: IE 64-bit tab` is now passing
