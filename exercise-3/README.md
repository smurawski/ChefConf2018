# More advanced recipe work

## Dealing with Windows permissions

* In the editor, open ./spec/unit/recipe/default_spec.rb
* Change line 23-27 to be

```
  context 'When all attributes are default, on the Windows 2012 R2 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end
```

### Run the almost default spec test

* Open a PowerShell session as an administrator
* In the PowerShell session:

```
chef shell-init powershell | iex
cd ~/chefconf2017/mwwfy
delivery local unit
```

### Update the test to check for permissions to be assigned

* In the editor, edit ./spec/unit/recipe/default_spec.rb
* Just under line 31, add

```
    context 'file[c:\hello.txt]' do
      it 'sets Read for Everyone' do
        expect(chef_run).to create_file('c:\hello.txt').with(
          rights: [{ permissions: :full_control, principals: 'ChefPowerShell'},
                   { permissions: :read, principals: 'Everyone' }]
        )
      end
    end
```

* In the PowerShell session

```
delivery local unit
```

* In the editor, open ./recipes/default.rb
* Edit the `file` resource to look like

```
file 'c:\hello.txt' do
  content "Chef's gonna reboot your server. Ha Ha."
  action :create
  notifies :reboot_now, 'reboot[Restarting for fun and profit]', :immediately
  rights :read, 'Everyone'
end
```

* In the PowerShell session

```
delivery local unit
```

* In the editor, open ./recipes/default.rb
* Edit the `file` resource to look like

```
file 'c:\hello.txt' do
  content "Chef's gonna reboot your server. Ha Ha."
  action :create
  notifies :reboot_now, 'reboot[Restarting for fun and profit]', :immediately
  rights :full_control, 'ChefPowerShell'
  rights :read, 'Everyone'
end
```

* In the PowerShell session

```
delivery local unit
kitchen converge
```

## Working with PowerShell script guards

### Add a resource to install Chocolatey

* In the editor, open ./recipes/default.rb
* Add the `powershell_script` resource to the bottom of the recipe

```
powershell_script 'Chocolatey' do
  code <<-EOH
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  EOH
end
```

* In the PowerShell session

```
kitchen converge
```

### Add a guard so that we only install chocolatey if it is missing

* In the editor, open ./recipes/default.rb
* Edit the `powershell_script` resource to look like

```
powershell_script 'Chocolatey' do
  code <<-EOH
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  EOH
  not_if 'Test-Path $env:programdata\chocolatey\bin\choco.exe'
end
```

* In the PowerShell session

```
kitchen converge
```

## Using DSC resources in Chef recipes

### Starting with in-box resources

* In the editor, open ./recipes/default.rb
* Add the `dsc_resource` resource to the bottom of the recipe

```
dsc_resource 'IIS' do
  resource :windowsfeature
  property :name, 'web-server'
end
```

* In the PowerShell session

```
kitchen converge
```

### And the resource is well-behaved

* In the PowerShell session

```
kitchen converge
```

### Adding a community resource

* In the editor, open ./recipes/default.rb
* Add the following resources to the bottom of the recipe

```
# PowerShell 5 introduces side by side versioning
# And if there are multiple versions, dsc_resource requires
# us to supply a version

x_web_administration_version = '1.17.0.0'

powershell_package "xWebAdministration" do
  version x_web_administration_version
end

dsc_resource 'Default Web Site' do
  resource :xWebSite
  module_name 'xWebAdministration'
  module_version x_web_administration_version
  property :name, 'Default Web Site'
  property :state, 'Stopped'
end

dsc_resource 'ChefConf Workshop Site' do
  resource :xWebSite
  module_name 'xWebAdministration'
  module_version x_web_administration_version
  property :name, 'ChefConf'
end
```

* In the PowerShell session

```
kitchen converge
```
