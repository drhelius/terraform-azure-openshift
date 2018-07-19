terraform-azure-openshift
=========================

[OpenShift Reference Architecture](https://blog.openshift.com/openshift-container-platform-reference-architecture-implementation-guides/) implementation on Azure using Terraform.

Follow me on Twitter for updates: http://twitter.com/drhelius

![OpenShift Azure](https://blog.openshift.com/wp-content/uploads/refarch-ocp-on-azure-v6.png)

Bootstraping
------------
### Setup
Make sure you have Terraform in your PATH.

Log in into Azure using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):

```
az login
```

Modify the variables in ```bootstrap.tfvars``` to change the name of the resource group, number of nodes, size and OS of the VMs and the domains or subdomains that will be associated with OpenShift:

```
azure_location = "East US"
azure_resource_group_name = "openshift"
openshift_node_count = "2"
openshift_master_count = "3"
openshift_infra_count = "2"
openshift_node_vm_size = "Standard_B2s"
openshift_master_vm_size = "Standard_B2s"
openshift_infra_vm_size = "Standard_B2ms"
openshift_bastion_vm_size = "Standard_B2ms"
openshift_master_domain = "openshift.mydomain.com"
openshift_router_domain = "mydomain.com"
openshift_os_image_publisher = "OpenLogic"
openshift_os_image_offer = "CentOS"
openshift_os_image_sku = "7.5"
openshift_os_image_version = "latest"
openshift_vm_admin_user = "cloud-user"
```

### Bootstrap

Simply run:
```
./bootstrap.sh
```

When finished, you will get the public IPs for the Bastion host and for both the External Load Balancer and the Router Load Balancer.

In order to SSH into the Bastion host use the key in the ```certs``` folder:
```
ssh -i certs/bastion.key cloud-user@BASTION_IP
```

The ```oc``` command is configured to be used in the Bastion host.

If something failed during the installation you can run ```bootstrap.sh``` again.

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
