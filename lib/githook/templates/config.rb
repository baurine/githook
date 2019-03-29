set :pre_commit, fetch(:pre_commit, []).push(
  # uncomment following lines if it is a ruby project
  # 'pre_commit:rubocop',
  # 'pre_commit:rspec',

  # uncomment following lines if it is a java project built by gradle
  # 'pre_commit:checkstyle'

  # 'pre_commit:check_branch_name'
)

set :prepare_commit_msg, fetch(:prepare_commit_msg, []).push(
  # comment following lines if you want to skip it
  'prepare_commit_msg:prepare_for_ekohe_branch'
  # "prepare_commit_msg:prepare_for_gitlab_branch"
)
set :commit_msg, fetch(:commit_msg, []).push(
  # comment following lines if you want to skip it
  'commit_msg:check_msg_for_ekohe_format'
)
