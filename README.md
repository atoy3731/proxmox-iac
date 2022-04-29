# Proxmox K3s IaC

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