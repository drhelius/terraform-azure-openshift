terraform-azure-openshift
=========================

[OpenShift Reference Architecture](https://access.redhat.com/documentation/en-us/reference_architectures/2017/html-single/deploying_red_hat_openshift_container_platform_3.5_on_microsoft_azure/) implementation on Azure using Terraform. 

Follow me on Twitter for updates: http://twitter.com/drhelius

![OpenShift Azure](https://blog.openshift.com/wp-content/uploads/refarch-ocp-on-azure-v3.png)

Bootstraping
------------
### Setup
Fill in the variables in ```azure.tfvars``` by following the [Terraform docs](https://www.terraform.io/docs/providers/azurerm/index.html#creating-credentials):

```
azure_client_id = "xxxxxx-xx-xx-xx-xxxxxxx"  
azure_tenant_id = "xxxxxx-xx-xx-xx-xxxxxxx"  
azure_client_secret = "xxxx"  
azure_subscription_id = "xxxxxx-xx-xx-xx-xxxxxxx"
azure_location = "West Europe"
```

Modify the variables in ```bootstrap.tfvars``` to change the name of the resource group, the number of App nodes, the size of the VMs and the credentials used in all the machines:

```
resource_group_name = "openshift"
node_count = "2"
node_vm_size = "Standard_A2m_v2"
master_vm_size = "Standard_A2m_v2"
infra_vm_size = "Standard_A2m_v2"
bastion_vm_size = "Standard_A2"
admin_user = "openshift"
admin_password = "xxxxxxxx"
```

### Run

Simply run:
```
./bootstrap.sh
```
You will get as an output the public IPs for the Bastion host and for both the External Load Balancer and the Router Load Balancer.

In order to SSH into the Bastion host use the key in the ```certs``` folder.

License
-------
MIT License

Copyright (c) 2017 Ignacio Sanchez Gines

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
