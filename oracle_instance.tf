data "oci_identity_availability_domains" "all_availability_domains" {
  compartment_id = var.oci-info.tenancy-ocid
}

resource "oci_core_instance" "k8s-master" {
  compartment_id = var.oci-info.tenancy-ocid

  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  create_vnic_details {
    assign_private_dns_record = false
    assign_public_ip = "true"
    subnet_id = oci_core_subnet.public.id
  }
  shape_config {
    memory_in_gbs = 6
    ocpus = 1
  }
  source_details {
    boot_volume_size_in_gbs = "47"
    boot_volume_vpus_per_gb = "10"
    source_id               = "ocid1.image.oc1.ap-seoul-1.aaaaaaaahmqzbp27ijr22ycp4gabqbh7gtgvnls33yivtxkbtjfglja6drsa"
    source_type             = "image"
  }
  metadata = {
    "ssh_authorized_keys" = var.oci-else.oracle-instance-ssh-authorized-keys.k8s-master
  }
}

resource "oci_core_instance" "k8s-worker-1" {
  compartment_id = var.oci-info.tenancy-ocid

  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  create_vnic_details {
    assign_private_dns_record = false
    assign_public_ip = false
    subnet_id = oci_core_subnet.private.id
  }
  shape_config {
    memory_in_gbs = 6
    ocpus = 1
  }
  source_details {
    boot_volume_size_in_gbs = "47"
    boot_volume_vpus_per_gb = "10"
    source_id               = "ocid1.image.oc1.ap-seoul-1.aaaaaaaahmqzbp27ijr22ycp4gabqbh7gtgvnls33yivtxkbtjfglja6drsa"
    source_type             = "image"
  }
  metadata = {
    "ssh_authorized_keys" = var.oci-else.oracle-instance-ssh-authorized-keys.k8s-worker-1
  }
}

resource "oci_core_instance" "k8s-worker-2" {
  compartment_id = var.oci-info.tenancy-ocid

  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  create_vnic_details {
    assign_private_dns_record = false
    assign_public_ip = false
    subnet_id = oci_core_subnet.private.id
  }
  shape_config {
    memory_in_gbs = 6
    ocpus = 1
  }
  source_details {
    boot_volume_size_in_gbs = "47"
    boot_volume_vpus_per_gb = "10"
    source_id               = "ocid1.image.oc1.ap-seoul-1.aaaaaaaahmqzbp27ijr22ycp4gabqbh7gtgvnls33yivtxkbtjfglja6drsa"
    source_type             = "image"
  }
  metadata = {
    "ssh_authorized_keys" = var.oci-else.oracle-instance-ssh-authorized-keys.k8s-worker-2
  }
}

resource "oci_core_instance" "k8s-worker-3" {
  compartment_id = var.oci-info.tenancy-ocid

  availability_domain = data.oci_identity_availability_domains.all_availability_domains.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  create_vnic_details {
    assign_private_dns_record = false
    assign_public_ip = false
    subnet_id = oci_core_subnet.private.id
  }
  shape_config {
    memory_in_gbs = 6
    ocpus = 1
  }
  source_details {
    boot_volume_size_in_gbs = "47"
    boot_volume_vpus_per_gb = "10"
    source_id               = "ocid1.image.oc1.ap-seoul-1.aaaaaaaahmqzbp27ijr22ycp4gabqbh7gtgvnls33yivtxkbtjfglja6drsa"
    source_type             = "image"
  }
  metadata = {
    "ssh_authorized_keys" = var.oci-else.oracle-instance-ssh-authorized-keys.k8s-worker-3
  }
}