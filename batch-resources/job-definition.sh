cat > ~/environment/namd-aws-batch/test-job-definition.json << EOF
{
    "jobDefinitionName": "namd-job-definition",
    "type": "container",
    "parameters": {},
    "containerProperties": {
        "image": "$ECR_REPOSITORY_URI:latest",
        "vcpus": 4,
        "memory": 60000,
        "command": [],
        "jobRoleArn": "arn:aws:iam::$ACCOUNT:role/BatchJobRole",
        "volumes": [
            {
                "host": {
                    "sourcePath": "/scratch"
                },
                "name": "scratch"
            },
            {
                "host": {
                    "sourcePath": "/local"
                },
                "name": "local"
            }
        ],
        "environment": [
            {
                "name": "SCRATCH_DIR",
                "value": "/scratch"
            },
            {
                "name": "OMP_THREADS",
                "value": "2"
            },
            {
                "name": "MPI_THREADS",
                "value": "1"
            },
            {
                "name": "S3_OUTPUT",
                "value": "s3://namd-workshop-$POSTFIX"
            }
        ],
        "mountPoints": [
            {
                "containerPath": "/scratch",
                "sourceVolume": "scratch"
            },
            {
                "containerPath": "/usr/tmp",
                "sourceVolume": "local"
            }
        ],
        "ulimits": [
            {
                "hardLimit": -1,
                "name": "memlock",
                "softLimit": -1
            }
        ],
        "resourceRequirements": [
            {
                "value": "1",
                "type": "GPU"
            }
        ],
        "linuxParameters": {
            "devices": []
        }
    }
}
EOF