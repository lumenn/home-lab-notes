It's #iaac primarily made for deploying VM's in cloud, but there are extensions called providers, which allow to use it for [[Proxmox]] VM's management:
* [telmate](https://github.com/Telmate/terraform-provider-proxmox)
* [bpg](https://github.com/bpg/terraform-provider-proxmox)
This tool will help to automate VM creation based on existing templates.

There is Terraform [[VSCode]] extension, which helps with synatx, and provides a Language Server: [HashiCorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)


### Proxmox provider base config:

```
terraform {
	required_version = ">= 0.14"
	required_providers {
		proxmox = {
			source = "telmate/proxmox"
			version = ">= 1.0.0"
		}
	}
}
	
provider "proxmox" {
	pm_tls_insecure = true
	pm_api_url = "https://proxmox.domain/api2/json"
	pm_api_token_secret = "this is a secret"
	pm_api_token_id "this is a token api id generated in proxmox"
}
```


