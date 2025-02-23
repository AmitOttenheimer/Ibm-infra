terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.57.0"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

# Service ID Creation
resource "ibm_iam_service_id" "service_id" {
  name        = var.service_id_name
  description = "Service ID created using Terraform"
}

# Optional: API Key for the Service ID
resource "ibm_iam_service_api_key" "api_key" {
  name        = var.service_id_api_key_name
  iam_service_id = ibm_iam_service_id. service_id. iam_id
  description = "API Key for Service ID"
}


# Optional: Assign Policy to Service ID
resource "ibm_iam_service_policy" "policy" {
  iam_service_id = ibm_iam_service_id.service_id.id
  description    = "IAM Service Policy"
  roles = ["Viewer"]
}
