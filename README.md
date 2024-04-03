# backup script for postgres

## Preparation

This script needs many environment variables, so I recommend using [direnv](https://github.com/direnv/direnv)

Install some packages (direnv, psql, pg_dump, pg_restore, gnu-tar, pzstd)

```bash
# MacOS
$ brew install direnv postgresql zstd
echo 'export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.bashrc # BASH
echo 'export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"' >> ~/.zshrc # ZSH

# Arch Linux
$ sudo pacman -S postgresql-libs zstd
$ yay -S direnv
```

configure direnv

```bash
# BASH
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc

# ZSH
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

copy environment variable as .envrc

```bash
$ git clone git@github.com:pyar6329/postgres_utils.git
$ cd postgres_utils
$ cp .envrc.tpl .envrc
$ direnv allow
```

## Usage

```bash
$ make help
help                           show this help message.
copy                           pg_dump to $COMPRESSED_FILE_NAME.tar.zst
restore                        pg_restore from $COMPRESSED_FILE_NAME.tar.zst
psql                           psql and enter database
log                            show logging postgres
up                             run PostgreSQL container
run                            run PostgreSQL container. (it's sames to 'make up')
down                           shutdown PostgreSQL container
stop                           shutdown PostgreSQL container. (it's sames to 'make down')
clean                          remove container, data
```
