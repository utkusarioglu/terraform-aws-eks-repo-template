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
