terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}

provider "nsxt" {
  host                  = var.nsx_manager
  username              = var.nsx_username
  password              = var.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = "TNT65-OVERLAY-TZ"
}

data "nsxt_logical_tier0_router" "tier0_router" {
  display_name = "TNT65-T0"
}

data "nsxt_edge_cluster" "edge_cluster" {
  display_name = "TNT65-CLSTR"
}

data "nsxt_policy_tier1_gateway" "tier1_router" {
  display_name = "TNT65-T1"
}

data "nsxt_policy_service" "icmp" {
  display_name = "ICMPv4"
}

resource "nsxt_policy_dhcp_server" "ARC_DHCP" {
  display_name      = "Azure-ARC-DHCP"
  description       = "Azure Arc DHCP Server"
  edge_cluster_path = data.nsxt_policy_edge_cluster.EC.path
  lease_time        = 200
  server_addresses  = ["10.130.250.2/24"]
}

resource "nsxt_policy_dhcp_server" "CDS_DHCP" {
  display_name      = "CDS-on-AVS-DHCP"
  description       = "CDS DHCP Server"
  edge_cluster_path = data.nsxt_policy_edge_cluster.EC.path
  lease_time        = 200
  server_addresses  = ["10.130.20.2/24"]
}

resource "nsxt_policy_segment" "AVSTeam" {
  display_name        = "AVS-Team-Network"
  description         = "AVS-Team-Network"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.9.97/27"
  }
}

resource "nsxt_policy_segment" "AzureArc" {
  display_name = "Azure-ARC-Segment"
  # depends_on = [
  #   nsxt_policy_dhcp_server.ARC_DHCP
  # ]
  description         = "Arc-Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  dhcp_config_path    = nsxt_policy_dhcp_server.ARC_DHCP.path

  subnet {
    cidr        = "10.130.250.1/24"
    # dhcp_ranges = ["10.130.250.100-10.130.250.130"]


    dhcp_v4_config {
      server_address = "10.130.250.2/24"
      lease_time     = 86400
    }
  }
}

resource "nsxt_policy_segment" "Blue-Segment" {
  display_name        = "Blue-Segment-HCX-MON-Demo"
  description         = "MON-Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.100.1/24"
  }
}

resource "nsxt_policy_segment" "CDSTesting" {
  display_name = "CDS-on-AVS-Segment"
  # depends_on = [
  #   nsxt_policy_dhcp_server.CDS_DHCP
  # ]
  description         = "CDS Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_gw.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  dhcp_config_path    = nsxt_policy_dhcp_server.CDS_DHCP.path

  subnet {
    cidr        = "10.130.20.1/24"
    dhcp_ranges = ["10.130.20.100-10.130.20.130"]

    dhcp_v4_config {
      server_address = "10.130.20.2/24"
      lease_time     = 36000
    }
  }
}

resource "nsxt_policy_segment" "CDSTesting2" {
  display_name        = "CDS-on-AVS-Segment"
  description         = "CDS-Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  

  subnet {
    cidr = "10.130.20.1/24"
  }
}

resource "nsxt_policy_segment" "CSRDownlink" {
  display_name        = "Cisco_CSR_Downlink"
  description         = "Cisco CSR Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_gwC.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.131.2/24"
  }
}

resource "nsxt_policy_segment" "CSRDownlink2" {
  display_name        = "Cisco_CSR_Downlink2"
  description         = "Cisco CSR Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_gwD.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.132.2/24"
  }
}

resource "nsxt_policy_segment" "CSRUplink" {
  display_name        = "Cisco_CSR_Uplink"
  description         = "Cisco CSR Testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_gwB.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.130.1/24"
  }
}

resource "nsxt_policy_segment" "GraySegment" {
  display_name        = "Gray-Segment-HCX-MON-NVA-Demo"
  description         = "HCX MON testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_gwC.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.101.1/24"
  }
}

resource "nsxt_policy_segment" "OrangeSegment" {
  display_name        = "Orange-Segment-HCX-MON-NVA-Demo"
  description         = "HCX MON testing"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_gwB.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.130.8.1/24"
  }
}

resource "nsxt_policy_segment" "Webbma-Dpools" {
  display_name        = "Webbma-vnet-dptesting-8-129"
  description         = "Webb Testing D Pools"
  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = "10.118.8.129/26"
  }
}

data "nsxt_policy_tier0_gateway" "T0" {
  display_name = "TNT65-T0"
}

data "nsxt_policy_edge_cluster" "EC" {
  display_name = "TNT65-CLSTR"
}

data "nsxt_policy_tier1_gateway" "tier1_gw" {
  display_name = "CDS-on-AVS-T1"
  depends_on = [
    nsxt_policy_tier1_gateway.tier1_gw
  ]
}

data "nsxt_policy_tier1_gateway" "tier1_gwB" {
  display_name = "Router(B)_HCX_MON_Demo"
  depends_on = [
    nsxt_policy_tier1_gateway.tier1_gwB
  ]
}

data "nsxt_policy_tier1_gateway" "tier1_gwC" {
  display_name = "Router(C)_Isolated_HCX_MON_NVA_Demo"
  depends_on = [
    nsxt_policy_tier1_gateway.tier1_gwC
  ]
}

data "nsxt_policy_tier1_gateway" "tier1_gwD" {
  display_name = "Router(D)_Isolated_HCX_MON_NVA_Demo"
  depends_on = [
    nsxt_policy_tier1_gateway.tier1_gwD
  ]
}

resource "nsxt_policy_tier1_gateway" "tier1_gw" {
  description               = "CDS T1"
  display_name              = "CDS-on-AVS-T1"
  nsx_id                    = "predefined_id2"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.EC.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.T0.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"


}

resource "nsxt_policy_tier1_gateway" "tier1_gwB" {
  description               = "HXC MON Demo B"
  display_name              = "Router(B)_HCX_MON_Demo"
  nsx_id                    = "predefined_id3"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.EC.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.T0.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"

}

resource "nsxt_policy_tier1_gateway" "tier1_gwC" {
  description               = "HCX MON Demo C"
  display_name              = "Router(C)_Isolated_HCX_MON_NVA_Demo"
  nsx_id                    = "predefined_id4"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.EC.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.T0.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"

}

resource "nsxt_policy_tier1_gateway" "tier1_gwD" {
  description               = "HCX MON Demo D"
  display_name              = "Router(D)_Isolated_HCX_MON_NVA_Demo"
  nsx_id                    = "predefined_id"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.EC.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.T0.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"

}
