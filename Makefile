MAKEFLAGS += --silent
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

REPO_SSH="git@github.com:pabloripoll/viatech.git"
REPO_URL="https://github.com/pabloripoll/viatech.git"
PROD_USER="1"
PROD_PORT="1"
PROD_ADDR="127.0.0.1"
PROD_DIR="/www/var/"

help: ## Show this help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# Version Control - To change repository ssh address edit .git/config file
repo-local-test:  ## Test remote git repository conecction.
	git remote -v
	git ls-remote $(REPO_SSH)

# Repository start
branch ?= master
repo-local-init:
	echo "# viatech" >> README.md; \
	git init; \
	git config user.email "<insert-personal-email>"; \
	git config user.name "<inser-your-name>"; \
	git add README.md; \
	git commit -m "first commit"; \

repo-local-start:
	git remote add origin ${REPO_URL}; \
	git branch -M ${branch}; \
	git push -u origin ${branch}; \

# Flush local cache when does not perform changes - specially with .gitignore file
repo-local-cache-clear:
	git rm -rf --cached .; \
	git add .; \
	git commit -m ".gitignore was updated"; \

# Specific branch $ make repo-update branch=??? comment="???" or by default master branch $ make repo-update
branch ?= master
comment ?= maint: $(shell date +"%Y%m%d%H%M%S")
repo-remote-update: ## Commits the HEAD of remote git repository branch.
	@echo ${C_YEL}"ATTENTION:"${C_END}
	@echo "All local changes from branch:"
	git branch;
	@echo "Is going to be pushed into * "${C_YEL}"$(branch)"${C_END}" branch,"
	@echo "On repository" ${C_YEL}$(shell git config --get remote.origin.url)${C_END}
	@echo "with the following commit comment:"
	@echo "*" ${C_GRN}${comment}${C_END};
	@echo -n ${C_YEL}"Are you sure? "${C_END}"[Y/n]: " && read response && if [ $${response:-'n'} != 'Y' ]; then \
        echo ${C_RED}"K.O.! process has been stopped."${C_END}; \
    else \
		git stash; \
		git pull origin master; \
		git stash pop; \
		git add .; \
		git commit -m "$(comment)"; \
		git push origin -u master; \
        echo ${C_GRN}"O.K.! process has been finished."${C_END}; \
    fi
