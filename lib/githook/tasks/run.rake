desc "Run hook tasks"
task :run do |t|
  hook = ENV["HOOK"]
  if hook
    Githook::Util.log_task(hook)
    Githook::Util.run_tasks(hook.to_sym)
  end
end
