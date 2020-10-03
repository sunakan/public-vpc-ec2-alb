################################################################################
# 変数
################################################################################
CFN_STACK_NAME := $(shell basename $(PWD))

################################################################################
# タスク
################################################################################
.PHONY: create-stack
create-stack: ## 適用
	aws cloudformation create-stack --stack-name $(CFN_STACK_NAME) --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --template-body file://./main.yaml

.PHONY: validate
validate: ## up テンプレートの検証
	aws cloudformation validate-template --template-body file://main.yaml

.PHONY: update-stack
update-stack: ## 適用
	aws cloudformation update-stack --stack-name $(CFN_STACK_NAME) --template-body file://./main.yaml

.PHONY: delete-stack
delete-stack: ## 削除
	aws cloudformation delete-stack --stack-name $(CFN_STACK_NAME)

.PHONY: list-stacks
list-stacks:
	aws cloudformation list-stacks | jq '.StackSummaries[] | select(.StackStatus != "DELETE_COMPLETE")'
