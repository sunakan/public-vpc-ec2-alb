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
#.PHONY: create-s3-bucket
#create-s3-bucket: ## S3バケット作成
#	aws s3api create-bucket --bucket $(S3_BUCKET_NAME) --create-bucket-configuration LocationConstraint=$(AWS_DEFAULT_REGION)
.PHONY: remove-s3-bucket
remove-s3-bucket: ## S3バケットにあるコンテンツを全て削除
	grep TemplateURL $(CFN_OUTPUT_FILE_NAME) \
		| head -n 1 \
		| awk '{ print $$2 }' \
		| xargs -I {url} dirname {url} \
		| xargs -I {url} basename {url} \
		| xargs -I {s3-bucket-name} aws s3 rb s3://{s3-bucket-name} --force
	rm $(CFN_OUTPUT_FILE_NAME)

.PHONY: package
package:
	$(eval S3_BUCKET_NAME := $(shell grep TemplateURL $(CFN_OUTPUT_FILE_NAME) | head -n 1 | awk '{ print $$2 }' | xargs -I {url} dirname {url} | xargs -I {url} basename {url}))
	$(eval TEMP_S3_BUCKET_NAME := $(shell echo "cfn-$(shell date +'%Y%m%d-%H%M%S')-$(shell uuidgen)"))
	if [ -n "$(S3_BUCKET_NAME)" ]; then \
		aws cloudformation package --template-file ./main.yaml --s3-bucket $(S3_BUCKET_NAME) --output-template-file $(CFN_OUTPUT_FILE_NAME); \
	else \
		aws s3api create-bucket --bucket $(TEMP_S3_BUCKET_NAME) --create-bucket-configuration LocationConstraint=$(AWS_DEFAULT_REGION); \
		aws cloudformation package --template-file ./main.yaml --s3-bucket $(TEMP_S3_BUCKET_NAME) --output-template-file $(CFN_OUTPUT_FILE_NAME); \
	fi

.PHONY: create-stack
create-stack: ## 適用
	aws cloudformation create-stack \
		--stack-name $(CFN_STACK_NAME) \
		--template-body file://$(CFN_OUTPUT_FILE_NAME) \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--parameters \
			ParameterKey=Env,ParameterValue=dev

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
	aws cloudformation delete-stack --stack-name $(CFN_STACK_NAME)

