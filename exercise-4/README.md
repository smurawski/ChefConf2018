# Building Custom Resources With PowerShell

## Creating the resource

* Open a PowerShell session as an administrator
* In the PowerShell session:

```
chef shell-init powershell | iex
cd ~/chefconf2017/mwwfy
mkdir resources
```

* In the editor, add ./resources/netadapter.rb

```
resource_name :net_adapter

property :interface_alias, String,  name_property: true
property :interface_index, Integer
```

### Adding a bit of PowerShell and Loading the Current State

* In the editor, edit ./resources/netadapter.rb to include 


```
load_current_value do |desired|
  require 'chef/util/powershell/cmdlet'
  interface_command = if desired.interface_index.nil?
                        "Get-NetAdapter -InterfaceAlias #{desired.interface_alias}"                        
                      else
                        "Get-NetAdapter -InterfaceIndex #{desired.interface_index}"
                      end
  interface_cim_object = (Chef::Util::Powershell::Cmdlet.new(node, interface_command, :object).run!).return_value
  interface_index interface_cim_object['InterfaceIndex'].to_i
  interface_alias interface_cim_object['InterfaceAlias']
end
```

### Another method to call out to PowerShell

* In the editor, edit ./resources/netadapter.rb to include 

```
action :rename do
  new_resource.interface_alias new_resource.name unless property_is_set? :interface_alias

  converge_if_changed :interface_alias do
    powershell_out!("Get-NetAdapter -InterfaceIndex #{current_resource.interface_index} | Rename-NetAdapter -NewName #{new_resource.interface_alias}")
  end
end
```


### Try our resource

* In the PowerShell session:

```
kitchen exec -c 'get-netadapter'
```

* In the editor, edit ./recipes/default.rb to include

```
net_adapter "Local" do
  interface_index 6 # USE THE INTERFACE INDEX RETURNED BY OUR COMMAND ABOVE
end
```

* In the PowerShell session:

```
kitchen converge
kitchen exec -c 'get-netadapter'
```


### Adding platform and OS version awareness

* In the editor, edit ./resources/netadapter.rb to include just under line 1

```
provides :net_adapter, platform: 'windows' do |node|
  ::Gem::Version.new(node['platform_version']) >= ::Gem::Version.new('6.2')
end
```
