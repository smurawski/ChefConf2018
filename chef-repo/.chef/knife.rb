# See https://docs.chef.io/azure_portal.html#azure-marketplace/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'chefpowershell'
client_key               "#{current_dir}/chefpowershell.pem"
validation_client_name   "cc2017-validator"
validation_key           "#{current_dir}/cc2017-validator.pem"
chef_server_url          "https://chefmurawski.southcentralus.cloudapp.azure.com/organizations/cc2017"
cookbook_path            ["#{current_dir}/../cookbooks"]
