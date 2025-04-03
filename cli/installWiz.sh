#!/bin/bash

# Ensure IBM Cloud CLI is logged in
if ! ibmcloud account show &>/dev/null; then
    echo "You are not logged in. Please log in using 'ibmcloud login' first."
    exit 1
fi

# Extract the current account ID
ENT_ACCOUNT_ID=$(ibmcloud account show --output JSON | jq -r '.account_id')

# Check if the account ID was retrieved
if [ -z "$ENT_ACCOUNT_ID" ]; then
    echo "Failed to retrieve IBM Cloud account ID."
    exit 1
fi

# Export as an environment variable
export IBM_CLOUD_ENT_ACCOUNT_ID="$ENT_ACCOUNT_ID"

echo "IBM Cloud Account ID: $ENT_ACCOUNT_ID"

# Update JSON file with the new account ID
JSON_FILE="wiz_viewer_platform_services.json"
jq --arg account_id "$ENT_ACCOUNT_ID" '.account_id = $account_id' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"
echo "Updated account_id in $JSON_FILE"

ibmcloud iam access-policy-template-create --file "$JSON_FILE"
echo "Access policy template created from $JSON_FILE"

JSON_FILE="wiz_viewer_services.json"
jq --arg account_id "$ENT_ACCOUNT_ID" '.account_id = $account_id' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"
echo "Updated account_id in $JSON_FILE"

ibmcloud iam access-policy-template-create --file "$JSON_FILE"
echo "Access policy template created from $JSON_FILE"

ibmcloud iam access-policy-template-version-commit Wiz_Viewer_platform_services 1
ibmcloud iam access-policy-template-version-commit Wiz_Viewer_services 1

view_platform_services_policy_name="Wiz_Viewer_platform_services"
view_services_policy_name="Wiz_Viewer_services"


# Fetch the list of access policy templates in JSON format
TEMPLATE_JSON=$(ibmcloud iam ap-templates --output JSON)

# Extract the ID and version for the given policy name
view_platform_services_policy_id=$(echo "$TEMPLATE_JSON" | jq -r --arg name "$view_platform_services_policy_name" '.[] | select(.name == $name) | .id')

# Check if values were retrieved
if [ -z "$view_platform_services_policy_id" ]; then
    echo "Failed to retrieve ID for policy: $view_platform_services_policy_name"
    exit 1
fi

view_services_policy_id=$(echo "$TEMPLATE_JSON" | jq -r --arg name "$view_services_policy_name" '.[] | select(.name == $name) | .id')

# Check if values were retrieved
if [ -z "view_services_policy_id" ]; then
    echo "Failed to retrieve ID for policy: $view_services_policy_name"
    exit 1
fi



# Export as environment variables
export view_platform_services_policy_id
export view_services_policy_id


echo "Policy Platform Services Template ID: $view_platform_services_policy_id"
echo "Policy Services Template ID: $view_services_policy_id"

JSON_FILE="wiz_trusted_profile_template.json"
IAM_ID="iam-ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"
IDENTIFIER="ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"

jq --arg account_id "$ENT_ACCOUNT_ID" \
   --arg iam_id "$IAM_ID" \
   --arg identifier "$IDENTIFIER" \
   --arg id_1 "$view_platform_services_policy_id" \
   --arg id_2 "$view_services_policy_id" \
   '.account_id = $account_id |
     .profile.identities[0].iam_id = $iam_id |
     .profile.identities[0].identifier = $identifier |
     .policy_template_references[0].id = $id_1 |
     .policy_template_references[1].id = $id_2' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"

echo "Updated $JSON_FILE with new values"

ibmcloud iam trusted-profile-template-create --file "wiz_trusted_profile_template.json"
ibmcloud iam trusted-profile-template-version-commit "wiz_trusted_profile_template" 1

TEMPLATE_JSON=$(ibmcloud iam tp-template-version wiz_trusted_profile_template 1 --output JSON)

view_trusted_profile_template_id=$(echo "$TEMPLATE_JSON" | jq -r '.id')

if [ -z "$view_trusted_profile_template_id" ]; then
    echo "Failed to retrieve Trusted Profile Template ID"
    exit 1
fi

echo "Policy Trusted Profile Template ID: $view_trusted_profile_template_id"

ACCOUNTS_JSON=$(ibmcloud enterprise accounts --recursive -o json)

# Extract account IDs
ACCOUNT_IDS=$(echo "$ACCOUNTS_JSON" | jq -r '.[].id')

# Check if any accounts were found
if [ -z "$ACCOUNT_IDS" ]; then
    echo "No accounts found in the enterprise."
    exit 1
fi

# Loop through each account ID and assign the trusted profile
for ACCOUNT_ID in $ACCOUNT_IDS; do
    echo "Assigning trusted profile to account: $ACCOUNT_ID"

    if [ "$ACCOUNT_ID" == "$ENT_ACCOUNT_ID" ]; then
        echo "Skipping the current account: $ACCOUNT_ID as it is the enterprise account."
        continue
    fi

    ibmcloud iam trusted-profile-assignment-create "$view_trusted_profile_template_id" 1 \
        --target-type Account --target "$ACCOUNT_ID"

    if [ $? -ne 0 ]; then
        echo "Failed to assign trusted profile to account: $ACCOUNT_ID"
    else
        echo "Successfully assigned trusted profile to account: $ACCOUNT_ID"
    fi
done

ACCOUNTS_GROUPS_JSON=$(ibmcloud enterprise account-groups --recursive -o json)

# Extract account IDs
ACCOUNT_GROUP_IDS=$(echo "$ACCOUNTS_GROUPS_JSON" | jq -r '.[].id')

# Check if any accounts were found
if [ -z "ACCOUNT_GROUP_IDS" ]; then
    echo "No accounts groups found in the enterprise."
    exit 1
fi

# Loop through each account ID and assign the trusted profile
for ACCOUNT_GROUP_ID in $ACCOUNT_GROUP_IDS; do
    echo "Assigning trusted profile to account: $ACCOUNT_GROUP_ID"

    ibmcloud iam trusted-profile-assignment-create "$view_trusted_profile_template_id" 1 \
        --target-type AccountGroup --target "$ACCOUNT_GROUP_ID"

    if [ $? -ne 0 ]; then
        echo "Failed to assign trusted profile to account: $ACCOUNT_GROUP_ID"
    else
        echo "Successfully assigned trusted profile to account: $ACCOUNT_GROUP_ID"
    fi
done