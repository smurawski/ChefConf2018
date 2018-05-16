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
cp <PATH-TO-LOCAL-EXERCISES-FOLDER>/exercise-2/.kitchen.local.yml -destination .
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

## TODO: Inspec run (Trevor)


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
