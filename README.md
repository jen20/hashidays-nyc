# HashiCorp Stack on AWS

This repository is the accompanying code for James Nugent's talk at HashiDays
New York 2017. It demonstrates deploying the HashiCorp runtime stack (Consul,
Nomad and Vault) in a production quality fashion on AWS.

*Note: The code in this repository will provision real resources in AWS which
cost real money! Be careful!*

## Usage

The following steps cover local usage from Mac OS X. The steps from Illumos or
Linux are similar, and all processes post-key generation can be run under a
continuous integration system such as [TeamCity][teamcity] or
[Jenkins][jenkins].

Unlike many Terraform demonstrations, there is no single step to "build the
world". Instead, Terraform state files are layered together. For ease of
distribution, everything is contained in one repository, though this may not be
optimal depending on the quality of the CI tools in use. In a production
system, many of the steps for generating initial secrets would likely not be
carried out on a developer workstation, but instead on an appropriately secured
system.

### Install software prerequisites

On Mac OS X, you will need the following tools, available via Homebrew or Ruby
Gems, or via building with Go:

HashiCorp tools:

- `packer` - `brew install packer`
- `terraform` - `brew install terraform`

Tools for shell scripts:

- `gfind` - `brew install findutils`
- `gtar` - `brew install gnu-tar`
- `gnupg` - `brew install gnupg`
- `wget` - `brew install wget`

Tools for building packages:

- `fpm` - `gem install fpm`
- `deb-s3` - `gem install deb-s3`

Tools for converting human-friendly formats into Packer input:

- `cfgt` - `go get github.com/sean-/cfgt`

In addition the following tools are recommended, though not required:

- `envchain` - `brew install envchain`
- `viscosity` - `brew cask install viscosity`

### Create a Terraform Remote State Bucket and bootstrap your account

For the purposes of this guide, we are going to use an S3 bucket _in the same
account_ for storing Terraform state. There is no reason this has to be the
case - you could put it in a separate account, or, better, on a separate
hosting provider.

Although we will use Terraform to create the remote state bucket, the state
used for the composition root which creates it will not be managed with remote
state, since a chicken-and-egg problem exists. Instead, we will abandon this
state by writing it to `/dev/null` - also protecting against rogue accidental
`terraform destroy` operations which could be catastrophic for future
management.

It is worth nothing that Terraform Enterprise does not require this step, since
it manages state storage internally.

Create a set of root credentials for an empty AWS account (things may work with
resources already in existence, but this is completely untested). These will be
used to execute the Terraform which creates the remote state bucket, as well as
in the next step to enable CloudTrail, create a password policy, and create
some buckets for logs, bootstrap TLS keys and to create a user from which all
other Terraform will be executed (likely the set handed to your CI system).

First, edit `terraform/GNUmakefile` with a unique bucket name for state. These
must be globally unique (and the default in this repository is already in use!)

Then, Run the following commands with the root `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` set in your environment:

```
cd terraform
make state-bootstrap
# Check the plan
make state-bootstrap ACTION=apply

make account-bootstrap
# Check the plan
make account-bootstrap ACTION=apply
```

Following this, the root account credentials *should be deleted* and should not
used as a matter of course. The credentials created for the Terraform account
should be used from hereon in.

### Build a Base AMI

All of the infrastructure in this repository uses ZFS on Ubuntu 16.04. Despite
claims to the contrary, EBS can and does corrupt data, and ZFS can protect
against this (in fact, ZFS corrected errors on EBS volumes during preparation
of this material). In particular for customer data, running a filesystem
_other_ than ZFS in production is negligent.

Since we will use ZFS for all data, we may as well use it for root volumes
also, and get benefits such as pooled storage and snapshots. The directory
`packer/base-os-ami` contains a Packer template which will scratch-build an
Ubuntu 16.04 AMI (using `debootstrap`) with a ZFS root filesystem. It is
described in detail in [a post on my blog][zfspost]. To build the base AMI, run
the following commands, with AWS credentials present in your environment:

```
cd packer
make base-os-ami
```

### Build a VPC

The VPC composition root creates a VPC following all known AWS best practices -
public and private subnets distributed over three availability zones, a VPC
endpoint for S3, NAT and Internet gateways with appropriate routing tables for
each subnet. Flow logs are also enabled, along with a DHCP options set
customizing the domain name assigned to new instances.

Customise the description, region and address space in the
`roots/base_vpc/main.tf` file, and then run the following commands with the
non-root AWS credentials created in the last step:

```
cd terraform
make base-vpc
# Check the plan
make base-vpc ACTION=apply
```

### Create an S3 bucket and policy for the APT repository

All software should be delivered to machines via the operating system native
package manager. In order to do this, we will need to build custom packages for
all of the HashiCorp tools (HashiCorp still do not provide them), and for our
configurations. We will use S3 as the package manager repository, and need to
build the packages before we can build an environmental base image on top of
our generic ZFS root AMI built previously.

APT packages are stored in an S3 bucket in the correct structure to be used
with `apt-get`. Since using S3 requires credentials and a special transport
plugin to be installed, we instead enable static site hosting on the S3 bucket
_from within the VPC we created earlier_. This is effected by way of the S3
bucket policy. Access from outside of the VPC (for example from the CI server
which building the packages) still requires credentials.

The `apt_repo` Terraform composition root makes use of the `base_vpc`
composition root outputs in order to populate the VPC ID.

Note: Later on, we will use the [`deb-s3`][debs3] utility to upload packages
and metadata to the repository and sign them using a GPG key we will create.
Unfortunately, if the name of the S3 bucket is a valid DNS name, `deb-s3` will
fail under many circumstances. This took too long to find, at some point in
time. Consequently we create a second "staging" bucket with a `deb-s3`
compatible name, and synchronise the content to the main repository using `aws
s3 sync`.  This has the added benefit that if a package or metadata upload
fails the main repository bucket is less likely to become corrupted.

To build the APT repository, run the following commands with non-root AWS
credentials in your environment:

```
cd terraform
make apt-repo
# Check the plan
make apt-repo ACTION=apply
```

### Generate and upload an APT Repository signing key

**Generally this step would not be carried out on a developer workstation.**


APT repositories are signed with a GPG key. Generate a new key pair using the
following commands:

```
gpg --full-gen-key
```

Select the default options for key type (RSA and RSA), for key size (2048
bits), and `0` for expiry time, indicating an infinite lifetime.

Use something recognizable for real name, email address and comment:

```
Real name: Operator Error Operations
Email address: ops@operator-error.com
Comment: APT Repository Signing Key
You selected this USER-ID:
    "Operator Error Operations (APT Repository Signing Key) <ops@operator-error.com>"
```

Use a secure (i.e. password-manager managed) passphrase for the key pair.

Once the key is generated, it should be present in the output of the command
`gpg --list-keys`:

```
$ gpg --list-keys
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/Users/James/.gnupg/pubring.kbx
-------------------------------
pub   rsa2048 2017-05-12 [SC]
      C6398F90FA354C7FA2D411B82CE07C37E69C1453
uid           [ultimate] Operator Error Operations (APT Repository Signing Key) <ops@operator-error.com>
sub   rsa2048 2017-05-12 [E]
```

You should also have a corresponding secret key shown in the output of `gpg
--list-secret-keys`:

```
$ gpg --list-secret-keys
/Users/James/.gnupg/pubring.kbx
-------------------------------
sec   rsa2048 2017-05-12 [SC]
      C6398F90FA354C7FA2D411B82CE07C37E69C1453
uid           [ultimate] Operator Error Operations (APT Repository Signing Key) <ops@operator-error.com>
ssb   rsa2048 2017-05-12 [E]
```

Back up the key files in a safe place. The public and secret key material can
be exported using the following commands, replacing the key ID with the one
generated in the steps above:

```
$ gpg --output apt_pub.gpg --armor --export C6398F90FA354C7FA2D411B82CE07C37E69C1453
$ gpg --output apt_sec.gpg --armor --export-secret-key C6398F90FA354C7FA2D411B82CE07C37E69C1453
```

Note that the passphrase is required to export the secret key.


Uupdate `packaging/GNUmakefile` with the ID of the generated key for the
variable `APT_SIGNING_FINGERPRINT`.

Finally, upload the public key material to the stage repository bucket created
earlier by using the following command from the root of the repository, with
AWS credentials in your environment, substituting your key ID:

```
stage_bucket=$(cd terraform/roots/apt_repo && terraform output stage)
gpg --armor --export C6398F90FA354C7FA2D411B82CE07C37E69C1453 | \
    aws s3 cp - s3://${stage_bucket}/apt.key
```

### Generate an SSH Root Certificate

**Generally this step would not be carried out on a developer workstation.**

We use an [SSH Certificate][sshcert] to authenticate access to instances where
necessary. The OpenSSH configuration is delivered via a Debian package, and so
needs to be generated _a priori_.

Generate a key using the following commands (run from the root of the
repository):

```
ORIG=$(umask)
umask 77
mkdir ssh-ca
ssh-keygen -C "SSH Certificate Authority" -f ./ssh-ca/ca
umask ${ORIG}
```

Use a strong passphrase for the key, and back up the key files stored under
`ssh-ca` in a safe place - the directory _is ignored in Git_.

### Generate TLS Root Certificate

**Generally this step would not be carried out on a developer workstation.**

All HashiCorp runtime products support TLS. We use self-signed certificate
authorities for these. Terraform is used to create the root and intermediate
certificates and keys, and the certificates are built into the base AMI using
an operating system package.

Generate the certificate roots using the following commands (run from the root
of the repository), with AWS credentials in your environment:

```
cd tls-ca
make cas
```

### Build Packages

**Generally this step would not be carried out on a developer workstation.**

Debian packages for the various HashiCorp and external tools as well as the SSH
configuration and TLS CA Root certificates can now be built. This process is
driven by [`fpm`][fpm] rather than the native Debian packaging tools, as we
don't necessarily care about the distribution standards.

We can use the `world` target in the `GNUmakefile` in the `packaging` directory
to build all packages in one go, and then use the `repo` target to upload them
to the repository we created earlier.

Run the following commands to build and upload the packages:

```
cd packaging
make world

# Ensure that AWS credentials are in your environment for these steps
export APT_SIGNING_PASSPHRASE=...
make repo
```

### Build an Environmental Base AMI

Next, we can take the generic ZFS root Ubuntu AMI we created eariler, and
specialize it for future uses, by installing some common packages including our
SSH configuration and our root certificates, and a dynamic MOTD to present
useful information when a user signs in.

We'll use Packer to build this AMI. Many variables need to be set in order to
build the image correctly. If using something like TeamCity or Terraform
Enterprise, these would be set in the UI, however running via Make from the
command line, we'll pass them via the environment:

```
export PACKER_VPC_ID=$(cd terraform/roots/base_vpc && terraform output vpc_id)
export PACKER_SUBNET_ID=$(cd terraform/roots/base_vpc && terraform output public_subnet_ids | head -n 1 | tr -d ",")
export PACKER_APT_REPO=http://$(cd terraform/roots/apt_repo && terraform output bucket)
export PACKER_CA_ROOTS_PACKAGE=hashistack-ca-roots
export PACKER_SSH_CA_PACKAGE=openssh-ca-config
export PACKER_ENVIRONMENT=HashiStack Staging
export AWS_REGION=us-west-2

cd packer
make base-os-config
```

### Build a Consul Server AMI

Now we have the base AMI with our customizations, we can start to build
application servers. The first one we'll do is Consul. The AMI will be
configured to self-bootstrap into a Consul Server cluster when run in an
Autoscaling group with approriate settings. All of the configuration to
actually do that is delivered in a package - `consul-bootstrap-aws`.

As Consul has data stored in it, we'll use a pair of mirrored ZFS EBS volumes
in their own pool, with a dataset for each service running on the box. 100GB is
likely on the high side for what is necessary, but EBS performance is tied to
volume size for GP2 type volumes, so a little extra cost for headroom in both
space and performance is a good idea.

```
export PACKER_VPC_ID=$(cd terraform/roots/base_vpc && terraform output vpc_id)
export PACKER_SUBNET_ID=$(cd terraform/roots/base_vpc && terraform output public_subnet_ids | head -n 1 | tr -d ",")
export PACKER_ENVIRONMENT=Staging
export AWS_REGION=us-west-2

cd packer
make consul-server
```

### Build the infrastructure for Consul Servers

We can now use our Consul Server AMI to build the infrastructure which supports
it - an autoscaling group, policies and so forth. This is all provisioned via
Terraform.

To built it, run the following commands:

```
cd terraform
make consul-servers

# Check the plan
make consul-servers ACTION=apply
```

#### Experiment with Consul Autopilot

Once the infrastructure comes up, satisfy yourself of the following:

- The Consul servers have their private IP addresses attached to a DNS A
  record at `consul` for the VPC private hosted zone. 

- Instances in the VPC can find Consul servers by resolving `consul` using `dig
  +search consul`.

- Terminating an instance replaces it with a new server, automatically joining
  the cluster.

- Consul manages the quorum correctly, removing the dead server.

- `journald` logs from the Consul servers are streaming to CloudWatch.

[teamcity]: https://www.jetbrains.com/teamcity/
[jenkins]: https://jenkins.io/index.html
[sshcert]: https://support.ssh.com/manuals/server-admin/64/userauth-cert.html
[zfspost]: https://operator-error.com/2017/03/02/building-zfs-root-ubuntu-amis-with-packer/
[fpm]: https://github.com/jordansissel/fpm
[debs3]: https://github.com/krobertson/deb-s3
