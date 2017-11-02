# you can uncomment following lines if it is a ruby project
# set :pre_commit, fetch(:pre_commit, []).push(
#   'pre_commit:rubocop',
#   'pre_commit:rspec',
# )
set :prepare_commit_msg, fetch(:prepare_commit_msg, []).push(
  'prepare_commit_msg:prepare'
)
set :commit_msg, fetch(:commit_msg, []).push(
  'commit_msg:check_msg'
)
