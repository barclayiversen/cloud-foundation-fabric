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

module "project" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=tf-training"
  name           = var.project_id
  project_create = var.project_create
  services = [
    "compute.googleapis.com",
    "dns.googleapis.com",
  ]
  service_config = {
    disable_on_destroy         = false
    disable_dependent_services = false
  }
}

module "service-accounts" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=tf-training"
  project_id = module.project.project_id
  name       = "gce-vm"
  iam_project_roles = {
    (var.project_id) = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}

module "addresses" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-address?ref=tf-training"
  project_id = module.project.project_id
  internal_addresses = {
    "ilb-left" = {
      region     = var.region,
      subnetwork = values(module.vpc-left.subnet_self_links)[0]
    }
  }
}
