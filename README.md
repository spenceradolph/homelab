# homelab

Homelab scripts and code.

# Packer Templates

- Edit credentials.pkr.hcl
- `cd ./packer-templates/ubuntu-server-jammy`
- `packer validate -var-file=../credentials.pkr.hcl ./ubuntu-server-jammy.pkr.hcl`
- `packer build -var-file=../credentials.pkr.hcl ./ubuntu-server-jammy.pkr.hcl`
