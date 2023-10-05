import json
import requests
import sys

def handler(event, context):
    print('------ EVENT ------')
    print(event)
    print('------ EVENT ------')


    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
