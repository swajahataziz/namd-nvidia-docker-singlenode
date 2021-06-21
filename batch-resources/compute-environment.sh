cat > ~/environment/namd-aws-batch/test-compute-environment.json << EOF
{
    "computeEnvironmentName": "namd-compute-environment",
    "type": "MANAGED",
    "state": "ENABLED",
    "computeResources": {
        "type": "EC2",
        "allocationStrategy": "BEST_FIT",
        "minvCpus": 0,
        "maxvCpus": 96,
        "desiredvCpus": 0,
        "imageId": $AMI_ID,
        "instanceTypes": [
            "p3.2xlarge"
        ],
        "subnets": $SUBNET_IDS
        ,
        "securityGroupIds": $SG_IDS,
        "instanceRole": "arn:aws:iam::$ACCOUNT:instance-profile/ecsInstanceRole",
        "tags": {}
    },
    "serviceRole": "arn:aws:iam::$ACCOUNT:role/AWSBatchServiceRole"
}
EOF