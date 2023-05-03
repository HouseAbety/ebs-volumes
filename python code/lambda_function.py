import boto3
import botocore
#import os if DryRun=True

#Make script suitable to be exceuted with Lambda function

def lambda_handler(event, context):

#EC2 client
    client = boto3.client('ec2')

    #EC2 client to describe volumes as response
    response = client.describe_volumes()

    ### Not needed for Lambda. Use when running locally if needed - line 31 DryRun=True
    ###if os.environ['DryRun'] == 'False' :
    ###    DryRun = False
    ###elif os.environ['DryRun'] == 'True' :
    ###    DryRun = True
    ###else: DryRun = True


    for result in response['Volumes']:
        VolumeId = result['VolumeId']
        VolumeType = result['VolumeType']
        ### Optional - Line 30 'if Size "<" , ">" , or "=" <integer>, and IOP "<" , ">" , or "=" <integer> etc..
        #Size = result['Size']
        #IOP = result['Iops']
        try:
            if VolumeType == 'gp2' :
                modify = client.modify_volume(VolumeId=VolumeId,VolumeType='gp3', DryRun=False)
                print(f"{VolumeId} changed to gp3")
            else:
                print(f"{VolumeId} does not fit criteria")
        except botocore.exceptions.ClientError as error:
            print(error)