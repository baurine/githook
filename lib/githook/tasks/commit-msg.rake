namespace :commit_msg do
  desc "Check commit msg style"
  task :check_msg do |t|
    Githook::Util.log_task(t.name)

    commit_msg_file = Githook::Util.commit_msg_file
    commit_msg = Githook::Util.get_commit_msg(commit_msg_file)
    puts "commit-msg:"
    puts commit_msg.join("\n")
    # can't use return in block
    # can't "exit 0" in advance, else will abort later tasks
    # but we can "exit 1" in advance
    # exit 0 if Githook::Util.expected_msg_format?(commit_msg)
    exit 1 unless Githook::Util.check_msg_format?(commit_msg)
  end
end

desc "Run all commit-msg hook tasks"
task :commit_msg do |t|
  Githook::Util.log_task(t.name)
  Githook::Util.run_tasks(t.name.to_sym)
end
