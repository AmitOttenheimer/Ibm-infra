terraform {
 required_providers {
   ibm = {
     source  = "IBM-Cloud/ibm"
     version = "1.75.2"
   }
 }
}

resource "ibm_iam_policy_template" "Wiz-Viewer-platform-services" {
  name = "Wiz View platform services"
  description = "Grant viewer access to service platform resources"
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
    roles = ["Viewer"]
  }
}

# Create second policy template
resource "ibm_iam_policy_template" "Wiz-Viewer-services" {
  name = "Wiz View services"
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
  name = var.trusted_profile_template_name
  description = var.trusted_profile_template_description
  profile {
    name = var.trusted_profile_name
    identities {
      iam_id = var.wiz_service_id_iam_id
      identifier = var.wiz_service_id_identifier
      type = "serviceid"
    }
  }
  policy_template_references {
    id = split("/", ibm_iam_policy_template.Wiz-Viewer-platform-services.id)[0]
    version = ibm_iam_policy_template.Wiz-Viewer-platform-services.version
  }
  policy_template_references {
    id = split("/", ibm_iam_policy_template.Wiz-Viewer-services.id)[0]
    version = ibm_iam_policy_template.Wiz-Viewer-services.version
  }
  committed = true
}

resource "ibm_iam_trusted_profile_template_assignment" "tp_assignment_instance" {
  for_each = toset(var.accounts)

  template_id      = split("/", ibm_iam_trusted_profile_template.Wiz_template.id)[0]
  template_version = ibm_iam_trusted_profile_template.Wiz_template.version
  target_type      = "Account"
  target           = each.value  # Using each item from the list

  depends_on = [
    ibm_iam_trusted_profile_template.Wiz_template
  ]
}

resource "ibm_iam_trusted_profile_template_assignment" "tp_assignment_instance_accountGroup" {
  for_each = toset(var.target_groups)

  template_id      = split("/", ibm_iam_trusted_profile_template.Wiz_template.id)[0]
  template_version = ibm_iam_trusted_profile_template.Wiz_template.version
  target_type      = "AccountGroup"
  target           = each.value  # Using each item from the list

  depends_on = [
    ibm_iam_trusted_profile_template.Wiz_template
  ]
}