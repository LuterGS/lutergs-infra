data "oci_identity_availability_domains" "all_availability_domains" {
  compartment_id = var.oracle-tenancy-ocid
}

resource "oci_core_virtual_network" "default" {
  compartment_id = var.oracle-tenancy-ocid
}

resource "oci_core_subnet" "default" {
  cidr_block = "10.0.0.0/24"
  compartment_id = var.oracle-tenancy-ocid
  vcn_id         = oci_core_virtual_network.default.id
}

resource "oci_core_security_list" "default" {
  compartment_id = var.oracle-tenancy-ocid
  display_name   = "Default Security List for vcn-20200910-0122"
  vcn_id         = oci_core_virtual_network.default.id

  // default egress 1
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
  }
  // default egress 1
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  // default ingress 1
  ingress_security_rules {
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 3
    }
  }
  // default ingress 2
  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }
  // default ingress for ping
  ingress_security_rules {
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 8
    }
  }

  // default ingress 3 - for ssh
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  // settings for k8s
  // default ingress port for control-plane
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  // default ingress for flannel commmunication
  ingress_security_rules {
    protocol = "17"
    source   = oci_core_subnet.default.cidr_block
    udp_options {
      min = 8472
      max = 8472
    }
  }
  // metric-server communication
  ingress_security_rules {
    protocol = "6"
    source   = oci_core_subnet.default.cidr_block
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 10250
      max = 10250
    }
  }
  // HA and etcd-communication
  ingress_security_rules {
    protocol = "6"
    source   = oci_core_subnet.default.cidr_block
    tcp_options {
      min = 2379
      max = 2380
    }
  }

  // for HTTP and HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

variable "canonical-ubuntu-22-04-minial-aarch64-20230928-image-ocid" {
  type = string
  description = "get from https://docs.oracle.com/en-us/iaas/images/image/a73bacfa-cf56-4833-9f83-13a261f9829c/"
  default = "ocid1.image.oc1.ap-seoul-1.aaaaaaaahmqzbp27ijr22ycp4gabqbh7gtgvnls33yivtxkbtjfglja6drsa"
}


resource "oci_core_instance" "k8s-master-bak" {
  display_name        = "k8s-master"
  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = false
    assign_public_ip          = "true"
    subnet_id                 = oci_core_subnet.default.id
  }
  compartment_id      = var.oracle-tenancy-ocid
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    vcpus = 1
    memory_in_gbs = 6
  }
  source_details {
    boot_volume_size_in_gbs = "50"
    boot_volume_vpus_per_gb = "10"
    source_id   = var.canonical-ubuntu-22-04-minial-aarch64-20230928-image-ocid
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.oracle-instance-ssh-authorized-keys.k8s-master
  }
}

resource "oci_core_instance" "k8s-worker-1-bak" {
  display_name        = "k8s-worker-1"
  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = false
    assign_public_ip          = "true"
    subnet_id                 = oci_core_subnet.default.id
  }
  compartment_id      = var.oracle-tenancy-ocid
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    vcpus = 1
    memory_in_gbs = 6
  }
  source_details {
    boot_volume_size_in_gbs = "50"
    boot_volume_vpus_per_gb = "10"
    source_id   = var.canonical-ubuntu-22-04-minial-aarch64-20230928-image-ocid
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.oracle-instance-ssh-authorized-keys.k8s-worker-1
  }
}

resource "oci_core_instance" "k8s-worker-2-bak" {
  display_name        = "k8s-worker-2"
  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = false
    assign_public_ip          = "true"
    subnet_id                 = oci_core_subnet.default.id
  }
  compartment_id      = var.oracle-tenancy-ocid
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    vcpus = 1
    memory_in_gbs = 6
  }
  source_details {
    boot_volume_size_in_gbs = "50"
    boot_volume_vpus_per_gb = "10"
    source_id   = var.canonical-ubuntu-22-04-minial-aarch64-20230928-image-ocid
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.oracle-instance-ssh-authorized-keys.k8s-worker-2
  }
}

resource "oci_core_instance" "k8s-worker-3-bak" {
  display_name        = "k8s-worker-3"
  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = false
    assign_public_ip          = "true"
    subnet_id                 = oci_core_subnet.default.id
  }
  compartment_id      = var.oracle-tenancy-ocid
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    vcpus = 1
    memory_in_gbs = 6
  }
  source_details {
    boot_volume_size_in_gbs = "50"
    boot_volume_vpus_per_gb = "10"
    source_id   = var.canonical-ubuntu-22-04-minial-aarch64-20230928-image-ocid
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.oracle-instance-ssh-authorized-keys.k8s-worker-3
  }
}

