# Azure Configuration for Terraform
# Prerequisites
In order to start using this project, you will need to first follow these steps:
- You will need to create an Azure account with an Azure subscription linked to this account.
- Download the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and select your corresponding OS. Then, follow the steps to make the correct installation in you PC.
- Install [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) and again, select the corresponding OS and follow the steps mentioned in the installation process.
- Finally, you will need to link `Azure CLI` with `Terraform CLI`, follow this [link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) that helps you with this configuration
# Installation

## Usage
Generate a `SSH key`, you can do either this command below or follow this [link](https://www.ssh.com/academy/ssh/keygen).

```bash
cd ~
ssh-keygen -t rsa -C "YOUR_EMAIL@<domain>.com"
```
**NOTE:** You will be prompt with a screen in the terminal that asks for a file name, you can hit enter or put something like `.ssh/<file_name>`. Remember always to put the key in the folder `.ssh`; if you don't have it you must create the folder. It's not necessary to add a Key Phrase to the Key.

Map the correct variables obtained in the previous steps to the file `terraform.tfvars`.
```json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

These values map to the Terraform variables like so:

- `appId` is the `client_id` defined above.
- `password` is the `client_secret` defined above.
- `tenant` is the `tenant_id` defined above.
- `ssh_key_path` is the value for `private_ssh_key`.
- `ssh_key_path` is the value for `public_ssh_key.pub`.

Now, to use this project run the command below to init terraform:

```bash
terraform init
```

Then, you will have to plan what Terraform will perform with the next command:
```bash
terraform plan
```

Finally, to deploy all the infrastructure (VM, VNet, Network Security Group, etc) run the following command:
```bash
terraform apply -auto-approve
```
**Note:** If you don't want to auto approve just delete the `-auto-approve` flag from the command.

## Help
If you want to delete the entire project after the deployment process you can use this command:
```bash
terraform destroy
```