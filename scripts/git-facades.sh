git_remote_add() {
  template_repo_origin=$1
  template_repo_url=$2

  # This next line is not silenced
  git remote add $template_repo_origin $template_repo_url --no-tags > /dev/null
  git remote set-url --push $template_repo_origin not-allowed > /dev/null
}
