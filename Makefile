# To apply self documented help command,
# make target with following two sharp '##' enable to show the help message.
# If you wish not to display the help message, create taget with no comment or single sharp to comment.

.PHONY:	help
help: ## show this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:	copy
copy: ## pg_dump to *.tar.zst
	@./copy.sh

.PHONY:	restore
restore: ## pg_restore from *.tar.zst
	@./restore.sh

.PHONY:	psql
psql: ## psql and enter database
	@./psql.sh

.PHONY:	up
up: ## run PostgreSQL container
	@./run_server.sh

.PHONY:	down
down: ## shutdown PostgreSQL container
	@if docker ps -a | grep postgres; then docker rm -vf postgres; fi

.PHONY:	clean
clean: ## remove container, data
	@make down
	@rm -rf data

