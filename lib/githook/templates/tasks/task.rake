# define yourself tasks here
# or put them in a new .rake file

# namespace :pre_commit do
#   desc 'Check branch name style'
#   task :check_branch_name do
#     expected_branch_reg = /^(feature|bug|hotfix|misc|refactor)\/(\d*)?(\w*)/
#     branch_name = Githook::Util.branch_name
#     if branch_name.include?('/')
#       valid = expected_branch_reg.match(branch_name)
#     else
#       valid = %w(develop staging master).include?(branch_name)
#     end
#     unless valid
#       puts "Branch name #{branch_name} doesn't match the expected foramt."
#       exit 1
#     end
#   end
# end
