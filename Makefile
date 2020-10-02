include makefiles/gitignore.mk
include makefiles/rq.mk
include makefiles/help.mk

################################################################################
# 変数
################################################################################

################################################################################
# マクロ
################################################################################

################################################################################
# タスク
################################################################################
.PHONY: build
build:
	docker-compose build

.PHONY: bash
bash:
	docker-compose run --rm cdk bash

.PHONY: chown
chown:
	sudo chown -R $(USER):$(USER) ./

.PHONY: deploy-docs
deploy-docs: ## ドキュメントをデプロイする
	git subtree push --prefix docs/html/ origin gh-pages
