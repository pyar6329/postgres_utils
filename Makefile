# To apply self documented help command,
# make target with following two sharp '##' enable to show the help message.
# If you wish not to display the help message, create taget with no comment or single sharp to comment.

.PHONY:	help
help: ## show this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:	copy
copy: ## pg_dump to $COMPRESSED_FILE_NAME.tar.zst
	@./copy.sh

.PHONY:	restore
restore: ## pg_restore from $COMPRESSED_FILE_NAME.tar.zst
	@./restore.sh

.PHONY:	s3_upload
s3_upload: ## upload $COMPRESSED_FILE_NAME.tar.zst to AWS S3. It stored to $OUTPUT_S3_URL
	@./s3_upload.sh

.PHONY:	s3_download
s3_download: ## download $COMPRESSED_FILE_NAME.tar.zst from AWS S3. It download from $OUTPUT_S3_URL
	@./s3_download.sh

.PHONY:	psql
psql: ## psql and enter database
	@./psql.sh

.PHONY: log
log: ## show logging postgres
	@docker logs -f postgres

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

