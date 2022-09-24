#!/bin/bash

source scripts/config.sh

if [[ "$(git remote)" != *"$TEMPLATE_REPO_ORIGIN"* ]];
then
  echo "Registering template repo with git"
  git remote add $TEMPLATE_REPO_ORIGIN $TEMPLATE_REPO_URL --no-tags
  git remote set-url --push $TEMPLATE_REPO_ORIGIN push-to-template-not-allowed
fi

git fetch template
git fetch origin

git status

template_date_human=$(git log template/main -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S')
template_date_epoch=$(date -d "$template_date_human" +%s)

if [ "$TEMPLATE_LAST_UPDATE" -lt "$template_date_epoch" ];
then
  green="\e[32m"
  end_color="\e[0m"
  echo 
  echo -e "${green}You have a template update!${end_color}"
  echo "To start, run \`scripts/git-start-template-update.sh\`"
  echo
fi
