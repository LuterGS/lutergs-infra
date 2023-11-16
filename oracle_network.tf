resource "oci_core_virtual_network" "default" {
  compartment_id = var.oci-info.tenancy-ocid

  cidr_blocks = ["10.0.0.0/16"]
  display_name = "lutergs-dev"
  is_ipv6enabled = false
}

resource "oci_core_dhcp_options" "default" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  domain_name_type = "CUSTOM_DOMAIN"
  options {
    custom_dns_servers  = []
    search_domain_names = []
    server_type         = "VcnLocalPlusInternet"
    type                = "DomainNameServer"
  }
}

resource "oci_core_internet_gateway" "default" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
}

resource "oci_core_nat_gateway" "default" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  block_traffic = false
}

resource "oci_core_service_gateway" "default" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  services {
    service_id   = "ocid1.service.oc1.ap-seoul-1.aaaaaaaajqph4epgmyaodyehthzt6egwhujh62xp3mpdebiflu6nhaogfazq"
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.default.id
  }
}

resource "oci_core_subnet" "public" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  cidr_block     = "10.0.0.0/24"
  dhcp_options_id = oci_core_dhcp_options.default.id
  prohibit_internet_ingress = false
  prohibit_public_ip_on_vnic = false
  route_table_id = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]
}

resource "oci_core_security_list" "public" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id


  egress_security_rules {     // allowing all egress
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol    = "all"
    stateless = false
  }

  ingress_security_rules {      // default ICMP local (type 3)
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 3
    }
  }
  ingress_security_rules {      // default ICMP local (type 4)
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }
  ingress_security_rules {      // allow ping from VCN network
    description = "Internal ping enabled"
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 8
    }
  }

  ingress_security_rules {      // allow SSH from all network
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {      // allow access K3S API server from all internet
    description = "K3s supervisor and Kubernetes API Server"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 6443
      min = 6443
    }
  }

  ingress_security_rules {      // allow access metric from public subnet (master nodes)
    description = "Kubelet metrics (inside subnet)"
    protocol    = "6"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 10250
      min = 10250
    }
  }
  ingress_security_rules {      // allow access metric from private subnet (worker nodes)
    description = "Kubelet metrics (from private subnet)"
    protocol    = "6"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 10250
      min = 10250
    }
  }

  ingress_security_rules {      // allow communicate via K3S Flannel VXLAN from public subnet (master nodes)
    description = "Required only for Flannel VXLAN (inside subnet)"
    protocol    = "17"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 8472
      min = 8472
    }
  }
  ingress_security_rules {      // allow communicate via K3S Flannel VXLAN from private subnet (worker nodes)
    description = "Required only for Flannel VXLAN (from private subnet)"
    protocol    = "17"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 8472
      min = 8472
    }
  }

  ingress_security_rules {      // allow communicate via K3S Flannel wireguard from public subnet (master nodes)
    description = "Required only for Flannel Wireguard with IPv4 (inside subnet)"
    protocol    = "17"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 51820
      min = 51820
    }
  }
  ingress_security_rules {      // allow communicate via K3S Flannel wireguard from private subnet (worker nodes)
    description = "Required only for Flannel Wireguard with IPv4 (from private subnet)"
    protocol    = "17"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 51820
      min = 51820
    }
  }

  ingress_security_rules {      // allow access HTTPS request from all internet (block access using HTTP)
    description = "enable only HTTP outbound traffic"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }
}




resource "oci_core_route_table" "private" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.default.id
  }
  route_rules {
    destination       = "all-icn-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = "ocid1.servicegateway.oc1.ap-seoul-1.aaaaaaaa2twivcqy6jrz3vmv2wvvuvef5ikx76y4vdn6satgpkmuzli3okjq"
  }
}

resource "oci_core_subnet" "private" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  cidr_block     = "10.0.1.0/24"
  dhcp_options_id = oci_core_dhcp_options.default.id
  prohibit_internet_ingress = true
  prohibit_public_ip_on_vnic = true
  route_table_id = oci_core_route_table.private.id
  security_list_ids = [oci_core_security_list.private.id]
}

resource "oci_core_security_list" "private" {
  compartment_id = var.oci-info.tenancy-ocid

  vcn_id         = oci_core_virtual_network.default.id
  egress_security_rules {     // allowing all egress
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol    = "all"
    stateless = false
  }

  ingress_security_rules {      // default ICMP local (type 3)
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 3
    }
  }
  ingress_security_rules {      // default ICMP local (type 4)
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }
  ingress_security_rules {      // allow ping from VCN network
    description = "Internal ping enabled"
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 8
    }
  }

  ingress_security_rules {      // allow SSH from public subnet
    protocol    = "6"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {      // allow access metric from public subnet (master nodes)
    description = "Kubelet metrics (from public subnet)"
    protocol    = "6"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 10250
      min = 10250
    }
  }
  ingress_security_rules {      // allow access metric from private subnet (worker nodes)
    description = "Kubelet metrics (inside subnet)"
    protocol    = "6"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 10250
      min = 10250
    }
  }

  ingress_security_rules {      // allow communicate via K3S Flannel VXLAN from public subnet (master nodes)
    description = "Required only for Flannel VXLAN (from public subnet)"
    protocol    = "17"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 8472
      min = 8472
    }
  }
  ingress_security_rules {      // allow communicate via K3S Flannel VXLAN from private subnet (worker nodes)
    description = "Required only for Flannel VXLAN (inside subnet)"
    protocol    = "17"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 8472
      min = 8472
    }
  }

  ingress_security_rules {      // allow communicate via K3S Flannel wireguard from public subnet (master nodes)
    description = "Required only for Flannel Wireguard with IPv4 (from public subnet)"
    protocol    = "17"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 51820
      min = 51820
    }
  }
  ingress_security_rules {      // allow communicate via K3S Flannel wireguard from private subnet (worker nodes)
    description = "Required only for Flannel Wireguard with IPv4 (inside subnet)"
    protocol    = "17"
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 51820
      min = 51820
    }
  }
}

resource "oci_core_public_ip" "default" {
  compartment_id = var.oci-info.tenancy-ocid

  display_name = "lutergs-public-ipv4"
  lifetime       = "RESERVED"
}