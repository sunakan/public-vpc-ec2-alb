################################################################################
# 変数
################################################################################
CFN_STACK_NAME := stack-01-vpc-only

################################################################################
# タスク
################################################################################
.PHONY: create-stack
create-stack: ## 適用
	aws cloudformation create-stack --stack-name $(CFN_STACK_NAME) --template-body file://./main.yaml

.PHONY: delete-stack
delete-stack: ## 削除
	aws cloudformation delete-stack --stack-name $(CFN_STACK_NAME)

.PHONY: list-stacks
list-stacks:
	aws cloudformation list-stacks | jq '.StackSummaries[] | select(.StackStatus != "DELETE_COMPLETE")'
