# Proxmox K3s IaC

## Prerequisites

* [Terraform](https://www.terraform.io/downloads)
* [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
* [SOPS](https://github.com/mozilla/sops#id3)
* [GPG](https://gnupg.org/download/)
* [Proxmox API Token](https://pve.proxmox.com/wiki/Proxmox_VE_API)

## Initial Setup

For sensitive values, Terragrunt gives you the ability to use SOPS to encrypt/decrypt them so they can be stored in Git. For the same of simplicity, this is using GPG.

#### Creating a GPG Key

1. Run `gpg --gen-key` and enter your name and email. When prompted for a password, just hit Enter to bypass setting one.

2. Acquire the GPG fingerprint by running `gpg --fingerprint` and finding the entry that matches your name/email. It should be the 2nd line of the output for yoru entry, for instance:

```
pub   ab12345 2022-04-22 [SC] [expires: 2024-04-21]
      AB12 CD34 EF56 GH78 IJ90  KL12 MN34 OP56 QR78 ST90
uid           [ultimate] John Doe <john.doe@example.com>
sub   cv25519 2022-04-22 [E] [expires: 2024-04-21]
```

3. Remove the spaces from your fingerprint, for instance this:

```
AB12 CD34 EF56 GH78 IJ90  KL12 MN34 OP56 QR78 ST90
```
Should be:
```
AB12CD34EF56GH78IJ90KL12MN34OP56QR78ST90
```

4. Update the `.sops.yaml` file with your fingerprint.

```
creation_rules:
- pgp: >-
    AB12CD34EF56GH78IJ90KL12MN34OP56QR78ST90
```

#### Creating the Ubuntu CloudInit Template

You'll need to run the following commands on each of your Proxmox nodes in the cluster (or copy the template between):

```
cd /tmp
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
virt-customize -a /tmp/focal-server-cloudimg-amd64.img --install qemu-guest-agent
virt-customize -a /tmp/focal-server-cloudimg-amd64.img --run-command "echo -n > /etc/machine-id"
touch /etc/pve/nodes/prox1/qemu-server/9991.conf
qm importdisk 9991 /tmp/focal-server-cloudimg-amd64.img local-lvm
qm set 9991 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9991-disk-0
qm set 9991 --ide2 local-lvm:cloudinit
qm set 9991 --boot c --bootdisk scsi0
qm set 9991 --serial0 socket --vga serial0
qm set 9991 --agent enabled=1
qm set 9991 --name ubuntu-ci-template
qm template 9991
```

**NOTE**: For each Proxmox node, you'll need to increase the ID (aka, 9991, 9992, 9993, etc.). They are globally unique.

# Installing to Proxmox

## Common

Under the `clusters` directory, you'll need to update the `prox_creds.enc.yaml` and `ssh_creds.enc.yaml` file with your values. Once updated, you'll need to run the follow commands to encrypt them with SOPS (ensure you've created your GPG key and updated the `.sops.yaml`):

```
cd clusters/
sops -i -e prox_creds.enc.yaml
sops -i -e ssh_creds.enc.yaml
```

## Pure K3s Cluster

This will install K3s without a reliance on Rancher MCM. It pulls the K3s binary from Github. You can always register this cluster with Rancher MCM after provisioning through the UI.

1. Copy the `k3s-example/` directory to another directory.

2. Update the `cluster_secrets.enc.yaml` with whatever join token you want and encrypt the file with:

```
cd clusters/name-of-your-dir/
sops -i -e cluster_secrets.enc.yaml
```

3. Update the `terragunt.hcl` file with your desired values.

4. In the directory that copied, go into it and run:

```
terragrunt plan
```

5. Assuming all is expect, running:

```
terragrunt apply -y
```

## Advanced K3s Cluster

For K3s clusters that need multiple agent nodepools with specific resources/labels/taints, you can use the `k3s-advanced` example.

1. Copy the `k3s-advanced-example/` directory to another directory.

2. Update the `cluster_secrets.enc.yaml` with whatever join token you want and encrypt the file with:

```
cd clusters/name-of-your-dir/
sops -i -e cluster_secrets.enc.yaml
```

3. Update the `cluster_configs.yaml` with the common values to be shared between your nodepools (ie. cluster name, dns servers, etc.)

4. Update the `terragunt.hcl` in the `controlplane`, `critical`, and `general` directories with your desired values. You can adjust the nodepool directory names as you wish, as well as add more.

5. Terrgrunt gives you 2 different ways to deploy multi-module TG:

  1. Deploy all together at once (less ideal, but quicker). Go into the parent-level `k3s-advanced-example` directory and run:

```
terragrunt run-all plan
```

  If that looks right, run:

```
terragrunt run-all apply
```

  2. Deploy separately (safer, but takes time). Starting with the `controlplane` directory, then moving to each agent directory:

```
terragrunt plan
```

  If that looks right, run:

```
terragrunt apply
```

## Rancher Provisioned Cluster

This utilizes's Rancher's custom cluster creation to automatically provision your cluster. The only dependency is `curl` and upon creation, the cluster will be in Rancher MCM.

1. Create a cluster in Rancher and acquire the Rancher token and checksum: (Provisioning Custom Cluster)[https://rancher.com/docs/rancher/v2.5/en/cluster-provisioning/rke-clusters/custom-nodes/]

2. Copy the `rancher-example/` directory to another directory.

3. Update the `cluster_secrets.enc.yaml` with whatever join token you want and encrypt the file with:

```
cd clusters/name-of-your-dir/
sops -i -e cluster_secrets.enc.yaml
```

4. Update the `terragunt.hcl` file with your desired values.

5. In the directory that copied, go into it and run:

```
terragrunt plan
```

5. Assuming all is expect, running:

```
terragrunt apply -y
```

## Updating resources

1. Update the `terragrunt.hcl` file with updatable things (resources, controlplane/worker node count, etc.)

2. Run `terragrunt plan` and make sure only expected values are updating.

3. Run `terragrunt apply` and type `yes`.

## Deleting clusters

1. In the cluster directory, run `terragrunt destroy`.