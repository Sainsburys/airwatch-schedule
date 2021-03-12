# AirWatch Schedule Action

This action schedules the activation date of an .apk or .ipa on an AirWatch smart group.

#### ⚠️  NOTE

```
The activation date will be the closest multiple of 5 minute time due to AirWatch limitations. e.g.
If the execution time is 15:57, the activation time will be 16:00
If the execution time is 16:01, the activation time will be 16:05
```

## Inputs

##### `api_host`

**Required** The base AirWatch URL to be used when activating the application.

##### `product_id`

**Required** The AirWatch product ID to be used when activating the application.
 
##### `organisation_group_id`

**Required** The AirWatch organisation group ID to be used when uploading the application.

##### `username`

**Required** The AirWatch username used for credentials.

##### `password`

**Required** The AirWatch password used for credentials.

##### `tenant_code`

**Required** The AirWatch tenant code used for credentials.

##### `product_name`

**Required** The product name used on AirWatch list of products.

##### `smartgroup_id`

**Required** The AirWatch ID of the smart group the activation should be scheduled.

##### `application_identifier`

**Required** The application identifier of the .apk or .ipa being uploaded.

##### `device_model_id`

**Required** The device model of the application to be uploaded.

| Model      | Value |
| ---------- | ----- |
| iOS        |   1   |
| Android    |   5   |

##### `step_type`

**Required** The action to be triggered on activation date.

| Step type               | Value |
| ----------------------- | ----- |
| Application - Install   |   3   |
| Application - Uninstall |   4   |

##### `application_version`

**Required** The version of the application to be activated.

##### `airwatch_application_identifier`

**Required** The ID given by AirWatch to the application upon [upload](https://github.com/marketplace/actions/airwatch-upload).

## Example usage

```
schedule-on-airwatch:
  runs-on: ubuntu-latest
  steps:
    - name: Schedule action step
      uses: edisonspencer/airwatch-schedule@1.0.0
      with:
        api_host: ${{ secrets.API_HOST }}
        product_id: ${{ secrets.PRODUCT_ID }}
        organisation_group_id: ${{ secrets.ORGANISATION_GROUP_ID }}
        username: ${{ secrets.USERNAME }}
        password: ${{ secrets.PASSWORD }}
        tenant_code: ${{ secrets.TENANT_CODE }}
        product_name: ${{ secrets.PRODUCT_NAME }}
        smartgroup_id: ${{ secrets.SMARTGROUP_ID }}
        application_identifier: ${{ secrets.APPLICATION_IDENTIFIER }}
        device_model_id: '5'
        step_type: '3'
        application_version: '0.0.112'
        airwatch_application_identifier: ${{ steps.upload.outputs.application_id }}
```