namespace :prepare_commit_msg do
  desc 'prepare commit msg'
  task :prepare do |t|
    Githook::Util.log(t.name)

    commit_msg_file = '.git/COMMIT_EDITMSG'
    # can't use return in block
    # can't "exit 0" in advance, else will abort later tasks
    # but we can "exit 1" in advance
    # exit 0 unless Githook::Util.commit_msg_empty?(commit_msg_file)

    if Githook::Util.commit_msg_empty?(commit_msg_file)
      branch_name = `git symbolic-ref --short HEAD`
      pre_msg = Githook::Util.gen_pre_msg(branch_name)
      puts "pre-msg: #{pre_msg}"
      Githook::Util.prefill_msg(commit_msg_file, pre_msg)
    end
  end
end

desc 'run all prepare-commit-msg hook tasks'
task :prepare_commit_msg do |t|
  Githook::Util.log(t.name)
  Githook::Util.run_tasks(t.name.to_sym)
end
