# Setup our providers so that we have deterministic dependecy resolution. 
provider "aws" {
  region  = "${var.region}"
  version = "~> 2.19"
  profile = "rh-spectre"
}

provider "local" {
  version = "~> 1.3"
}

provider "template" {
  version = "~> 2.1"
}

//  Create the OpenShift cluster using our module.
module "openshift" {
  source          = "./modules/openshift"
  region          = "${var.region}"
  amisize         = "t2.large"    //  Smallest that meets the min specs for OS
  vpc_cidr        = "10.0.0.0/16"
  subnet_cidr     = "10.0.1.0/24"
  key_name        = "openshift"
  public_key_path = "./hegira_id_rsa.pub"
  //public_key_path = "${var.public_key_path}"
  cluster_name    = "hegira"
  cluster_id      = "hegira-${var.region}"
  base_domain     = "ether.portalvein.io"
}

//  Output some useful variables for quick SSH access etc.

output "master-console" {
  value = "https://${module.openshift.cluster-console}:8443"
}

output "master-url" {
  value = "https://${module.openshift.master-public_ip}.xip.io:8443"
}
output "master-public_ip" {
  value = "${module.openshift.master-public_ip}"
}
output "bastion-public_ip" {
  value = "${module.openshift.bastion-public_ip}"
}
