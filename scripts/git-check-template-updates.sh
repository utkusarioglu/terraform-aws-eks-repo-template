source scripts/config.sh
source scripts/git-facades.sh

check_template_updates() {
  template_repo_origin=$1
  template_repo_branch=$2
  template_repo_url=$3
  template_last_commit_epoch=$4

  if [[ "$(git remote)" != *"$template_repo_origin"* ]];
  then
    git_remote_add $template_repo_origin $template_repo_url
  fi

  git fetch $template_repo_origin 1> /dev/null

  template_date_human=$(git log \
    $template_repo_origin/$template_repo_branch \
    -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S' \
  )
  template_date_epoch=$(date -d "$template_date_human" +%s)

  if [ "$template_last_commit_epoch" -lt "$template_date_epoch" ];
  then
    echo "$template_repo_origin has an update"
  fi

  git remote remove $template_repo_origin 1> /dev/null
}

if [ -f "$REPO_CONFIG_FILE" ];
then
  echo "Repo config file found at '$REPO_CONFIG_FILE'"
  repo_template_status=$(check_template_updates \
    $TEMPLATE_REPO_ORIGIN \
    $TEMPLATE_REPO_BRANCH \
    $TEMPLATE_REPO_URL \
    $TEMPLATE_LAST_COMMIT_EPOCH \
  )
fi

if [ -f "$TEMPLATE_CONFIG_FILE" ];
then
  echo "Template config file found at '$TEMPLATE_CONFIG_FILE'"
  source $TEMPLATE_CONFIG_FILE
  parent_template_status=$(check_template_updates \
    $TEMPLATE_REPO_ORIGIN \
    $TEMPLATE_REPO_BRANCH \
    $TEMPLATE_REPO_URL \
    $TEMPLATE_LAST_COMMIT_EPOCH \
  )
fi

display_repo_template_updates() {
  if [[ "$repo_template_status" == *"has an update"* ]]
  then
    echo -e "${green_text}You have a repo template update!${end_color}"
    echo "To start, run \`scripts/git-start-template-update.sh repo\`"
    echo
  fi
}

display_parent_template_updates() {
  if [[ "$parent_template_status" == *"has an update"* ]]
  then
    echo -e "${green_text}You have a parent template update!${end_color}"
    echo "To start, run \`scripts/git-start-template-update.sh parent\`"
    echo
  fi
}
