const amplifyconfig = '''{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
         
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "us-east-1_1vph21DjX",
                        "AppClientId": "4frfkri1535dldem3bh3bgfvue",
                        "Region": "us-east-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "usernameAttributes": [
                            "EMAIL"
                        ],
                          "signupAttributes": [
                            "EMAIL"
                        ],
                          "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": [
                                "REQUIRES_LOWERCASE",
                                "REQUIRES_NUMBERS",
                                "REQUIRES_SYMBOLS",
                                "REQUIRES_UPPERCASE"
                            ]
                        }
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                 "Endpoint": {
                     "endpointType": "REST",
                     "endpoint": "https://i1x4l94mh0.execute-api.us-east-1.amazonaws.com/prod",
                     "region": "us-east-1",
                     "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                    }    
            }
        }
    }
}''';
