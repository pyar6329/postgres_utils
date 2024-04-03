# To apply self documented help command,
# make target with following two sharp '##' enable to show the help message.
# If you wish not to display the help message, create taget with no comment or single sharp to comment.

.PHONY:	help
help: ## show this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:	copy
copy: ## pg_dump to '$COMPRESSED_FILE_NAME.tar.zst'
	@./copy.sh

.PHONY:	restore
restore: ## pg_restore from '$COMPRESSED_FILE_NAME.tar.zst'. Please remove records using 'make re_create_database' if the database have already data
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
	@./run_server.sh --up

.PHONY:	run
run: ## run PostgreSQL container. (it's sames to 'make up')
	@make up

.PHONY:	down
down: ## shutdown PostgreSQL container
	@./run_server.sh --down

.PHONY:	stop
stop: ## shutdown PostgreSQL container. (it's sames to 'make down')
	@make down

.PHONY:	re_create_database
re_create_database: ## drop database and create database. I suggest you to use this command before 'make restore'
	@./re_create_database.sh

.PHONY:	check_port
check_port: ## check port of PostgreSQL CLI can access or not
	@./check_port.sh

.PHONY:	clean
clean: ## remove container, data
	@make down
	@rm -rf data
