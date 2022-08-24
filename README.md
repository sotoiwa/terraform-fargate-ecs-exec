# terraform-fargate-ecs-exec

ECS Exec を実行するサンプル。

## デバッグコンテナの作成

ECR リポジトリの作成は Terraform の外でやる。

```sh
aws ecr create-repository --repository-name debug
```

イメージをビルドしてプッシュする。

```sh
cd image
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
AWS_REGION=$(aws configure get region)
aws ecr get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/debug .
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/debug
```

## インフラストラクチャーのデプロイ

Terraform で VPC、RDS、ECS クラスターなどをデプロイする。

```sh
cd ../../envs/dev
terraform init
terraform plan
terraform apply
```

Output に必要な情報があるので確認する。

```
ecs_cluster_name = "fargate-ecs-exec-cluster"
ecs_task_definition_arn = "arn:aws:ecs:ap-northeast-1:123456789012:task-definition/fargate-ecs-exec-taskdef:1"
private_subnet_a_id = "subnet-0f21842d33f6fec56"
private_subnet_c_id = "subnet-0d9427eecc4ce1414"
security_group_task_id = "sg-0fece328e21a0df1e"
```

## タスクの実行

ECS Exec を有効にしてスタンドアロンタスクを実行する。

```sh
CLUSTER_NAME="fargate-ecs-exec-cluster"
TASK_DEF_ARN="arn:aws:ecs:ap-northeast-1:123456789012:task-definition/fargate-ecs-exec-taskdef:1"
SUBNET_ID="subnet-0f21842d33f6fec56"
SECURITY_GROUP_ID="sg-0fece328e21a0df1e"
NETWORK_CONFIG="awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP_ID}],assignPublicIp=DISABLED}"
aws ecs run-task \
  --cluster "${CLUSTER_NAME}" \
  --task-definition "${TASK_DEF_ARN}" \
  --enable-execute-command \
  --network-configuration "${NETWORK_CONFIG}" \
  --launch-type FARGATE
```

タスクが RUNNING になるのを確認する。

```sh
$ aws ecs list-tasks --cluster "${CLUSTER_NAME}"
{
    "taskArns": [
        "arn:aws:ecs:ap-northeast-1:123456789012:task/fargate-bastion-cluster/23fa6847954045f39645485caa8d607c"
    ]
}
$ TASK_ARN=$(aws ecs list-tasks --cluster "${CLUSTER_NAME}" | jq -r '.taskArns[0]')
$ aws ecs describe-tasks --cluster "${CLUSTER_NAME}" --tasks "${TASK_ARN}" | jq -r '.tasks[].lastStatus'
RUNNING
```

## タスクへの接続

タスクに接続する。

```sh
TASK_ID=${TASK_ARN##*/}
aws ecs execute-command --cluster "${CLUSTER_NAME}" \
    --task "${TASK_ID}" \
    --container debug \
    --interactive \
    --command "/bin/sh"

The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.


Starting session with SessionId: ecs-execute-command-03837e0070f3aa0d3
sh-4.2# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 09:29 ?        00:00:00 sleep 3600
root         7     0  0 09:29 ?        00:00:00 /managed-agents/execute-command/amazon-ssm-agent
root        20     7  0 09:29 ?        00:00:00 /managed-agents/execute-command/ssm-agent-worker
root        32    20  1 09:29 ?        00:00:00 /managed-agents/execute-command/ssm-session-worker ecs-execute-command-03837e0070f3aa0d
root        42    32  0 09:29 pts/0    00:00:00 /bin/sh
root        44    42  0 09:29 pts/0    00:00:00 ps -ef
sh-4.2# /managed-agents/execute-command/amazon-ssm-agent --version
SSM Agent version: 3.1.1260.0
sh-4.2#
```
