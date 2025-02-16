## Prerequisites

Create S3 for Tofu states via this cloudformation template:

```bash
aws cloudformation create-stack --stack-name segator-tofu-states --template-body file://cloudformation-tofu-state.yaml
aws cloudformation wait stack-create-complete --stack-name segator-tofu-states
```

