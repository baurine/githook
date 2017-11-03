namespace :commit_msg do
  desc 'check commit msg style'
  task :check_msg do |t|
    Githook::Util.log(t.name)

    commit_msg_file = '.git/COMMIT_EDITMSG'
    commit_msg = Githook::Util.get_commit_msg(commit_msg_file)
    puts "commit-msg: #{commit_msg}"
    # can't use return in block
    # can't "exit 0" in advance, else will abort later tasks
    # but we can "exit 1" in advance
    # exit 0 if Githook::Util.expected_msg_format?(commit_msg)

    unless Githook::Util.expected_msg_format?(commit_msg)
      puts "ERROR! commit failed, commit msg doesn't match the required format"
      puts "expected msg format: FEAUTER|BUG|MISC|REFACTOR #issue_num - Content"
      exit 1
    end
  end
end

desc 'run all commit-msg hook tasks'
task :commit_msg do |t|
  Githook::Util.log(t.name)
  Githook::Util.run_tasks(t.name.to_sym)
end
