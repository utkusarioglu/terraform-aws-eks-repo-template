#!/bin/bash

source scripts/config.sh
# check_repo_config
check_template_config

DEFAULT_TEMPLATE_REMOTE_NAME="template"
DEFAULT_TEMPLATE_REMOTE_BRANCH="main"
DEFAULT_LOCAL_STAGING_BRANCH="chore/template-update"
default_merge_branch=$(git branch --show-current)

template_remote_name=${1:-$DEFAULT_TEMPLATE_REMOTE_NAME}
template_remote_branch=${2:-$DEFAULT_TEMPLATE_REMOTE_BRANCH}
local_staging_branch=${3:-$DEFAULT_LOCAL_STAGING_BRANCH}
merge_branch=${4:-$default_merge_branch}
template_ref="$template_remote_name/$template_remote_branch"
template_date_human=$(git log template/main -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S')
template_date_epoch=$(date -d "$template_date_human" +%s)

if [ "$1" == "--help" ] || [ "$1" == "-h" ];
then
  cat << EOF
Git template update
template-update.sh [...params]

Params in order (all optional):
  <template_remote_name>    Remote repository that hosts the template.
                            Default: $DEFAULT_TEMPLATE_REMOTE_NAME
  <template_remote_branch>  Remote branch that shall be used as the template
                            Default: $DEFAULT_TEMPLATE_REMOTE_BRANCH
  <local_staging_branch>    Local branch to be created for the template update
                            Default: $DEFAULT_LOCAL_STAGING_BRANCH
  <merge_branch>            The branch on which the changes shall be staged. 
                            Default: the current branch from which the script 
                            is called, currently: $default_merge_branch

This script uses '$template_ref' to create a new local branch named
'$local_staging_branch'. Script will terminate when it merges
all template changes on top of local branch '$merge_branch'.

EOF
  exit 0
fi

if [[ "$(git remote)" != *"$template_remote_name"* ]];
then
  echo "Error: Remote '$template_remote_name' not found among remotes."
  exit 1
fi

if [[ $(git branch) == *"$local_staging_branch"* ]];
then
  cat << EOF
Error: There is already a branch named '$local_staging_branch'. Either provide 
a different local branch name or delete the existing branch.
EOF
  exit 2
fi

if [[ $(git branch) != *"$merge_branch"* ]];
then
  cat << EOF
Error: There is no '$merge_branch' branch to merge upon. Please provide a branch that
already exists.
EOF
  exit 3
fi

echo "Template changes will be merged onto the branch '$merge_branch'"

git checkout -b $local_staging_branch
git fetch template

# Rewrites the last template update
record_target=$REPO_CONFIG_FILE
if [[ "$REPO_TYPE" == "template" ]];
  then
    record_target=$TEMPLATE_CONFIG_FILE
  fi
if [ ! -f $record_target ];

then
  touch $REPO_CONFIG_FILE
fi
sed -i '/TEMPLATE_LAST_COMMIT_EPOCH/d' $REPO_CONFIG_FILE 
echo "TEMPLATE_LAST_COMMIT_EPOCH=$template_date_epoch # $template_date_human" >> $REPO_CONFIG_FILE
# --

git merge \
  --squash \
  --allow-unrelated-histories \
  --strategy-option theirs \
  $template_ref
git reset --mixed $merge_branch

green="\e[32m"
end_color="\e[0m"
echo
echo -e "${green}Template update started${end_color}"
cat <<EOF

Current branch:  $local_staging_branch
Merge branch:    $merge_branch
Template branch: $template_remote_name/$template_remote_branch
Template url:    $TEMPLATE_REPO_URL
Template date:   $template_date_human

You can now reject the changes that you do not want, and then merge/rebase them 
with '$merge_branch' or any other branch you prefer.

Note that the \`$record_target.TEMPLATE_LAST_COMMIT_EPOCH\` now records the date of 
the last commit of the template. You should commit this line if you accept any
of the changes from the template repo.
EOF
