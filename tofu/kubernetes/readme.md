# Homelab Kube cluster


## Prerequisites

### PVE Token

To get a new one run this on proxmox
```
sudo pveum user add terraform@pve
sudo pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
sudo pveum aclmod / -user terraform@pve -role Terraform
sudo pveum user token add terraform@pve provider --privsep=0
```

Then you can save the token into sops `secrets/infra/secrets.yaml`