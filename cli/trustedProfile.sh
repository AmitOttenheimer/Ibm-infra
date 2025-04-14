#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
PROFILE_NAME="my-trusted-profile"  # Change this to your preferred profile name
PROFILE_DESCRIPTION="Trusted profile for viewing platform services and services"
POLICY_NAME="view-platform-services-policy"
SERVICE_ID="ServiceId-9b8290f1-5f77-4d62-a3f8-c79d51898457"  # Replace with your service ID

# Step 1: Create a trusted profile
echo "Creating trusted profile: $PROFILE_NAME..."
PROFILE_ID=$(ibmcloud iam trusted-profile-create "$PROFILE_NAME" -d "$PROFILE_DESCRIPTION" --output JSON | jq -r '.id')

if [ -z "$PROFILE_ID" ]; then
  echo "Error creating trusted profile."
  exit 1
fi
echo "Trusted profile created successfully with ID: $PROFILE_ID"

ibmcloud iam trusted-profile-policy-create --roles Viewer

# Step 3: Assign trusted profile to the service ID
echo "Assigning trusted profile to service ID: $SERVICE_ID..."
ibmcloud iam trusted-profile-identity-create "$PROFILE_NAME" --id "$SERVICE_ID" --id-type SERVICEID
echo "Trusted profile assigned to service ID successfully."

# Step 4: Output summary
echo "Script completed successfully!"
echo "Trusted Profile Name: $PROFILE_NAME"
echo "Trusted Profile ID: $PROFILE_ID"
echo "Service ID: $SERVICE_ID"