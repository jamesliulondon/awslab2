## Yaml Cloudformation


###### Create
```
aws cloudformation --profile accord create-stack --stack-name network --template-body file:///Users/jamliu1/code/learn/lit/awslab2/onesubnet/network.yml --parameter ParameterKey=EnvironmentName,ParameterValue=jamesliu
```


###### List
```
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
{
    "StackSummaries": [
        {
            "StackId": "arn:aws:cloudformation:eu-west-2:598559435893:stack/network/558bb8d0-ba58-11ea-9d9a-02949b77ae4a",
            "StackName": "network",
            "TemplateDescription": "This template deploys a VPC, with a pair of public and private subnets spread across two Availability Zones. It deploys an internet gateway, with a default route on the public subnets. It deploys a pair of NAT gateways (one in each AZ), and default routes for them in the private subnets.",
            "CreationTime": "2020-06-29T22:36:33.312000+00:00",
            "StackStatus": "CREATE_COMPLETE",
            "DriftInformation": {
                "StackDriftStatus": "NOT_CHECKED"
            }
        }
    ]
}
```


###### Describe:
```
aws cloudformation describe-stacks --stack-name network --output yaml
Stacks:
- CreationTime: '2020-06-29T22:36:33.312000+00:00'
  Description: This template deploys a VPC, with a pair of public and private subnets
    spread across two Availability Zones. It deploys an internet gateway, with a default
    route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
    and default routes for them in the private subnets.
  DisableRollback: false
  DriftInformation:
    StackDriftStatus: NOT_CHECKED
  EnableTerminationProtection: false
  NotificationARNs: []
  Outputs:
  - Description: A reference to the private subnet in the 1st Availability Zone
    OutputKey: PrivateSubnet1
[...]
  Timestamp: '2020-06-29T22:36:36.391000+00:00'
- EventId: fbba9960-ba58-11ea-a65d-029d9e7b7264
  LogicalResourceId: network
  PhysicalResourceId: arn:aws:cloudformation:eu-west-2:598559435893:stack/network/558bb8d0-ba58-11ea-9d9a-02949b77ae4a
  ResourceStatus: CREATE_IN_PROGRESS
  ResourceStatusReason: User Initiated
  ResourceType: AWS::CloudFormation::Stack
  StackId: arn:aws:cloudformation:eu-west-2:598559435893:stack/network/558bb8d0-ba58-11ea-9d9a-02949b77ae4a
  StackName: network
  Timestamp: '2020-06-29T22:36:33.312000+00:00'
```


###### List Resources:
```
aws cloudformation list-stack-resources --stack-name network
{
    "StackResourceSummaries": [
        {
            "LogicalResourceId": "DefaultPrivateRoute1",
            "PhysicalResourceId": "mytem-Defau-1CTXFSSYOIAQL",
            "ResourceType": "AWS::EC2::Route",
            "LastUpdatedTimestamp": "2020-06-29T22:39:34.575000+00:00",
            "ResourceStatus": "CREATE_COMPLETE",
            "DriftInformation": {
                "StackResourceDriftStatus": "NOT_CHECKED"
            }
        },
        {
            "LogicalResourceId": "DefaultPrivateRoute2",
            "PhysicalResourceId": "mytem-Defau-46MDPSBORA6M",
            "ResourceType": "AWS::EC2::Route",
            "LastUpdatedTimestamp": "2020-06-29T22:39:50.283000+00:00",
            "ResourceStatus": "CREATE_COMPLETE",
            "DriftInformation": {
                "StackResourceDriftStatus": "NOT_CHECKED"
            }
```


###### Retrieve Template:
```
aws cloudformation get-template --stack-name network
{
    "TemplateBody": "\nDescription:  This template deploys a VPC, with a pair of public and private subnets spread\n  across two Availability Zones. It deploys an internet gateway, with a default\n  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),\n  and default routes for them in the private subnets.\n\nParameters:\n  EnvironmentName:\n    Description: An environment name that is prefixed to resource names\n    Type: String\n\n  VpcCIDR:\n    Description:
[...]
he private subnet in the 1st Availability Zone\n    Value: !Ref PrivateSubnet1\n\n  PrivateSubnet2:\n    Description: A reference to the private subnet in the 2nd Availability Zone\n    Value: !Ref PrivateSubnet2\n\n  NoIngressSecurityGroup:\n    Description: Security group with no ingress rule\n    Value: !Ref NoIngressSecurityGroup",
    "StagesAvailable": [
        "Original",
        "Processed"
    ]
}
```


###### Validate Template:
```
aws cloudformation validate-template --template-url https://s3.amazonaws.com/cloudformation-templates-us-east-1/S3_Bucket.template
aws cloudformation validate-template --template-body file:///Users/jamliu1/code/learn/lit/awslab2/onesubnet/onesubnet/network.yml --output yaml
Description: This template deploys a VPC, with a pair of public and private subnets
  spread across two Availability Zones. It deploys an internet gateway, with a default
  route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
  and default routes for them in the private subnets.
Parameters:
- DefaultValue: 10.192.20.0/24
  Description: Please enter the IP range (CIDR notation) for the private subnet in
    the first Availability Zone
  NoEcho: false
  ParameterKey: PrivateSubnet1CIDR
```


###### Upload to S3:
```
aws cloudformation package --template /path_to_template/template.json --s3-bucket mybucket --output json > packaged-template.json
AWSTemplateFormatVersion: '2010-09-09'
Transform: 'AWS::Serverless-2016-10-31'
Resources:
  MyFunction:
    Type: 'AWS::Serverless::Function'
    Properties:
      Handler: index.handler
      Runtime: nodejs8.10
      CodeUri: s3://mybucket/lambdafunction.zip
```


###### Quickly Deploy with Transforms:
```
aws cloudformation deploy --template /path_to_template/my-template.json --stack-name my-new-stack --parameter-overrides Key1=Value1 Key2=Value2
```


###### Delete:
```
aws cloudformation delete-stack --stack-name network
```

