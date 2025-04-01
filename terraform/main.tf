terraform {
 required_providers {
   ibm = {
     source  = "IBM-Cloud/ibm"
     version = "1.75.2"
   }
 }
}

provider "ibm" {
  ibmcloud_api_key = "skorNgKF7gcNAxS75TNx6YB6my5hpkqtQHoot3o2SAuL"
  region           = "us-south"
}

# resource "ibm_iam_trusted_profile_template" "trusted_profile_template_instance" {
#   name = "${var.trusted_profile_name}"
#   description = "${var.trusted_profile_description}"
#   profile {
#     name = "profile from template"
#     description = "description of profile from template"
#     identities {
#       iam_id = "iam-ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"
#       identifier = "ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"
#       type = "serviceid"
#     }
#   }
#   committed = true
# }

# Create Kubernetes administrator policy template
resource "ibm_iam_policy_template" "Wiz-Viewer5" {
  name = "viewer 3"
  description = "Grant viewer access to all resources in the account"
  committed = true
  policy {
    type = "access"
    resource {
      attributes {
        key = "serviceType"
        operator = "stringEquals"
        value = "platform_service"
      }
    }
    resource {
      attributes {
        key = "serviceType"
        operator = "stringEquals"
        value = "service"
      }
    }
    roles = ["Viewer"]
  }
}

# Create second policy template
resource "ibm_iam_policy_template" "Wiz-Viewer6" {
  name = "viewer 4"
  description = "Grant viewer access to service type resources"
  committed = true
  policy {
    type = "access"
    resource {
      attributes {
        key = "serviceType"
        operator = "stringEquals"
        value = "service"
      }
    }
    roles = ["Viewer"]
  }
}

# Create SRE team Trusted profile template
resource "ibm_iam_trusted_profile_template" "Wiz_template" {
  name = "wiz"
  description = "wiz access"
  profile {
    name = "wiz profile"
    identities {
      iam_id = "iam-ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"
      identifier = "ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"
      type = "serviceid"
    }
  }
  policy_template_references {
    id = split("/", ibm_iam_policy_template.Wiz-Viewer5.id)[0]
    version = ibm_iam_policy_template.Wiz-Viewer5.version
  }
  policy_template_references {
    id = split("/", ibm_iam_policy_template.Wiz-Viewer6.id)[0]
    version = ibm_iam_policy_template.Wiz-Viewer6.version
  }
  committed = true
}

# Assign (or update) the trusted profile template to an account agroup
resource "ibm_iam_trusted_profile_template_assignment" "tp_assignment_instance" {
  template_id = split("/", ibm_iam_trusted_profile_template.Wiz_template.id)[0]
  template_version = ibm_iam_trusted_profile_template.Wiz_template.version
  target_type = "Account" // or "Account"
  target = "50907a4ca4fa496cae2e54b087da52d7" // or "<account id>"
  depends_on = [
    ibm_iam_trusted_profile_template.Wiz_template
  ]
}

resource "ibm_iam_trusted_profile_template_assignment" "tp_assignment_instance_accountGroup" {
  template_id = split("/", ibm_iam_trusted_profile_template.Wiz_template.id)[0]
  template_version = ibm_iam_trusted_profile_template.Wiz_template.version
  target_type = "AccountGroup" // or "Account"
  target = "285d1a15d4074b569d89c711ac0bf9d8" // or "<account id>"
  depends_on = [
    ibm_iam_trusted_profile_template.Wiz_template
  ]
}