/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "vpc-left" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=tf-training"
  project_id = module.project.project_id
  name       = "left"
  subnets = [
    {
      ip_cidr_range      = var.ip_ranges.left
      name               = "left"
      region             = var.region
      secondary_ip_range = {}
    },
  ]
  routes = {
    to-right = {
      dest_range    = var.ip_ranges.right
      priority      = null
      tags          = null
      next_hop_type = "ilb"
      next_hop      = module.ilb-left.forwarding_rule.self_link
    }
  }
}

module "firewall-left" {
  source               = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc-firewall?ref=tf-training"
  project_id           = module.project.project_id
  network              = module.vpc-left.name
  admin_ranges_enabled = true
  admin_ranges         = values(var.ip_ranges)
  ssh_source_ranges    = ["35.235.240.0/20", "35.191.0.0/16", "130.211.0.0/22"]
}

module "nat-left" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat?ref=tf-training"
  project_id     = module.project.project_id
  region         = var.region
  name           = "left"
  router_network = module.vpc-left.name
}
