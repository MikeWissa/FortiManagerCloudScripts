# FortiManager Cloud Scripts
Script to interact with FortiManager Cloud

This repo is aimed and providing instructions on how to interact with FortiManager Cloud API
# Steps
## Login to Support Portal IAM
This can be done by going to the https://support.fortiet.com/iam

![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/e0224598-1445-479b-a5c3-9909c2adc531)

## Create a permission Profile
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/6cfc2ab2-bc91-4b7e-ada9-8db326b3b535)

## Check the FortiManager Cloud Check Box
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/7f4def17-4138-49e3-845d-348b30f8ab72)

## Under permission choose read write permission
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/ca356a0c-1022-4753-b621-5ccdef35712c)

## Add New API User
Click on Add New and Provide a description as well as select the permisison profile you created.
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/0505cc7e-4e1b-47b7-9277-0f072a2aceb5)

### Confirm
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/fc380d8a-2a33-4a91-9a5a-ee85585b9e68)

## Click on Download Credentials
For security purposes the system asks for a password to ensure that the file is password protected.
### Provide the password
#### Download the file

## Once file is downloaded, unzip the file
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/2adbd10a-afc8-491b-9b3d-2c9275de91b7)
The first line is API key
The 2nd line is the password
For FortiManager Cloud the client_id is FortiManager

## Login to Fortimanager and Get the URL for your fortimanager instance
this should be https://something.us-region-something.fortimanager.forticloud.com

## git clone this repo

## Open the .env file and set the username, password which are api and password and the FortiManager Host URL instance

## Modify the variables.csv file to add one line for each device you want to add
![image](https://github.com/MikeWissa/FortiManagerCloudScripts/assets/6186228/e26abe85-fc5c-4d82-aef8-af5a16f70b8b)


