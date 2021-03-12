#!/bin/sh -l

set -e

if [ -z "$INPUT_API_HOST" ]; then
  echo "'api_host' was not provided"
  exit 1
fi

if [ -z "$INPUT_PRODUCT_ID" ]; then
  echo "'product_id' was not provided"
  exit 1
fi

if [ -z "$INPUT_ORGANISATION_GROUP_ID" ]; then
  echo "'organisation_group_id' was not provided"
  exit 1
fi

if [ -z "$INPUT_USERNAME" ]; then
  echo "'username' was not provided"
  exit 1
fi

if [ -z "$INPUT_PASSWORD" ]; then
  echo "'password' was not provided"
  exit 1
fi

if [ -z "$INPUT_TENANT_CODE" ]; then
  echo "'tenant_code' was not provided"
  exit 1
fi

if [ -z "$INPUT_PRODUCT_NAME" ]
then
  echo "'product_name' was not provided"
  exit 1
fi

if [ -z "$INPUT_SMARTGROUP_ID" ]
then
  echo "'smartgroup_id' was not provided"
  exit 1
fi

if [ -z "$INPUT_APPLICATION_IDENTIFIER" ]
then
  echo "'application_identifier' was not provided"
  exit 1
fi

if [ -z "$INPUT_DEVICE_MODEL_ID" ]
then
  echo "'device_model_id' was not provided"
  exit 1
fi

if [ -z "$INPUT_STEP_TYPE" ]
then
  echo "'step_type' was not provided"
  exit 1
fi

if [ -z "$INPUT_APPLICATION_VERSION" ]
then
  echo "'application_version' was not provided"
  exit 1
fi

if [ -z "$INPUT_AIRWATCH_APPLICATION_IDENTIFIER" ]
then
  echo "'airwatch_application_identifier' was not provided"
  exit 1
fi

AIRWATCH_CREDS=$(echo -n "$INPUT_USERNAME:$INPUT_PASSWORD" | base64)

# Deactivate the Product so that we don't affect its associated devices while we update the Product manifest

response=$(curl -X POST \
   -H 'Content-Type: application/json' \
   -H 'Accept: application/json' \
   -H "aw-tenant-code: ${INPUT_TENANT_CODE}" \
   -H 'Authorization: Basic '$AIRWATCH_CREDS'' \
   -d '{}' \
   $INPUT_API_HOST'/api/mdm/products/'$INPUT_PRODUCT_ID'/deactivate')

error_code=$(echo $response | jq -r ".errorCode")

if [ "$error_code" != '' ] && [ "$error_code" != 'null' ]; then
   echo "Failed to deactivate product"
   echo $response
   error_code=null
else
   echo "Product $INPUT_PRODUCT_ID has deactivated successfully"
fi

# Update the Product with the newly uploaded application

response=$(curl -X POST \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H "aw-tenant-code: ${INPUT_TENANT_CODE}" \
    -H 'Authorization: Basic '$AIRWATCH_CREDS'' \
    -d '{
    "MaintainGeneralInput": {
        "LocationGroupID": '$INPUT_ORGANISATION_GROUP_ID',
        "InsertOnly": false
    },
    "Product": {
        "Steps": [
            {
                "StepType": '$INPUT_STEP_TYPE',
                "SequenceNumber": '$INPUT_AIRWATCH_APPLICATION_IDENTIFIER',
                "Persist": false,
                "ApplicationBundleID": "'$INPUT_APPLICATION_IDENTIFIER'",
                "ApplicationPackageVersion": "'$INPUT_APPLICATION_VERSION'"
            }
        ],
        "Name": "'"$INPUT_PRODUCT_NAME"'",
        "Platform": '$INPUT_DEVICE_MODEL_ID',
        "ProductID": '$INPUT_PRODUCT_ID',
        "SmartGroups": [
            {
                "SmartGroupId": '$INPUT_SMARTGROUP_ID'
            }
        ]
    }
}' $INPUT_API_HOST'/api/mdm/products/maintainProduct')

error_code=$(echo $response | jq -r ".errorCode")

if [ "$error_code" != '' ] && [ "$error_code" != 'null' ]; then
   echo "Failed to maintain product"
   echo $response
   exit 1
fi

echo "Product $INPUT_PRODUCT_ID has been successfully maintained"

# Schedule the Product to activate in the next multiple of 5 minutes

# The following code is going to calculate the closest
# multiple of 5 minute time to set as a deployment time
# for the application we are deploying e.g.
# 15:57 > 16:00
# 16:01 > 16:05
givenDate=$(date +'%Y-%m-%d %T' --date="5 minutes")

echo $givenDate

minute=$(echo $givenDate | sed 's/.*\([0-9]\):..$/\1/')
rounder=$((5 - minute % 5))
finalDate=$(date +'%m/%d/%Y %H:%M' --date="$givenDate $rounder minutes")

echo $finalDate

response=$(curl -X POST \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H "aw-tenant-code: ${INPUT_TENANT_CODE}" \
-H 'Authorization: Basic '$AIRWATCH_CREDS'' \
-d "{
  \"ActivationDateTime\": \"$finalDate\"
}" $INPUT_API_HOST'/api/mdm/products/'$INPUT_PRODUCT_ID'/update')

error_code=$(echo $response | jq -r ".errorCode")

if [ "$error_code" != '' ] && [ "$error_code" != 'null' ]; then
   echo "Failed to update product"
   echo $response
   exit 1
fi

echo "Product $INPUT_PRODUCT_ID has been updated with activation date $finalDate"
