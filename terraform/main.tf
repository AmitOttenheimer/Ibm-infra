terraform {
 required_providers {
   ibm = {
     source  = "IBM-Cloud/ibm"
     version = "1.75.2"
   }
 }
}

resource "ibm_iam_trusted_profile" "example_profile" {
  name        = var.trusted_profile_name
  description = "Trusted profile for granting access to a service ID managed by Wiz"
}

resource "ibm_iam_trusted_profile_identity" "service_id_association" {
  identifier         = var.wiz_service_id
  identity_type      = "serviceid"
  profile_id         = ibm_iam_trusted_profile.example_profile.id
  type               = "serviceid"
}

resource "ibm_iam_trusted_profile_policy" "wiz_policy" {
  profile_id = ibm_iam_trusted_profile.example_profile.id
  roles = ["Viewer"]
}