################################################################################
# 変数
################################################################################
CFN_STACK_NAME       := $(shell basename $(PWD))
CFN_OUTPUT_FILE_NAME := output.yaml

ifdef AWS_DEFAULT_REGION
	AWS_DEFAULT_REGION := ${AWS_DEFAULT_REGION}
else
	AWS_DEFAULT_REGION := ap-northeast-1
endif

################################################################################
# タスク
################################################################################
.PHONY: create-main-vpc-stack
create-main-vpc-stack: ## 適用
	aws cloudformation create-stack --stack-name $(CFN_STACK_NAME)-vpc --template-body file://main-vpc.yaml --parameters ParameterKey=Env,ParameterValue=dev
.PHONY: create-main-public-subnets-stack
create-main-public-subnets-stack: ## 適用
	aws cloudformation create-stack --stack-name $(CFN_STACK_NAME)-public-subnets --template-body file://main-public-subnets.yaml --parameters ParameterKey=Env,ParameterValue=dev
.PHONY: create-main-intra-subnets-stack
create-main-intra-subnets-stack: ## 適用
	aws cloudformation create-stack --stack-name $(CFN_STACK_NAME)-intra-subnets --template-body file://main-intra-subnets.yaml --parameters ParameterKey=Env,ParameterValue=dev

.PHONY: validate
validate: ## up テンプレートの検証
	aws cloudformation validate-template --template-body file://main.yaml

.PHONY: update-stack
update-stack: ## 適用
	aws cloudformation update-stack \
		--stack-name $(CFN_STACK_NAME) \
		--template-body file://$(CFN_OUTPUT_FILE_NAME) \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--parameters \
			ParameterKey=Env,ParameterValue=dev

.PHONY: revoke-default-security-group-rules
revoke-default-security-group-rules:
	$(eval DEFAULT_SECURITY_GROUP_ID := $(shell aws cloudformation describe-stacks --stack-name '$(CFN_STACK_NAME)' | jq '.Stacks[].Outputs' | jq --raw-output '.[] | select(.OutputKey == "DefaultSecurityGroupId").OutputValue'))
	$(eval IP_PERMISSIONS := $(shell aws ec2 describe-security-groups --group-ids $(DEFAULT_SECURITY_GROUP_ID) | jq --raw-output --compact-output '.SecurityGroups[].IpPermissions'))
	if [ '$(IP_PERMISSIONS)' != '[]' ]; then \
		aws ec2 revoke-security-group-ingress --group-id $(DEFAULT_SECURITY_GROUP_ID) --ip-permissions '$(IP_PERMISSIONS)'; \
	fi
	$(eval IP_PERMISSION_EGRESS := $(shell aws ec2 describe-security-groups --group-ids $(DEFAULT_SECURITY_GROUP_ID) | jq --raw-output --compact-output '.SecurityGroups[].IpPermissionsEgress'))
	if [ '$(IP_PERMISSION_EGRESS)' != '[]' ]; then \
		aws ec2 revoke-security-group-egress --group-id $(DEFAULT_SECURITY_GROUP_ID) --ip-permissions '$(IP_PERMISSION_EGRESS)'; \
	fi

.PHONY: delete-stack
delete-stack: ## 削除
	aws cloudformation delete-stack --stack-name $(CFN_STACK_NAME)-vpc
	aws cloudformation delete-stack --stack-name $(CFN_STACK_NAME)-public-subnets
	aws cloudformation delete-stack --stack-name $(CFN_STACK_NAME)-intra-subnets
