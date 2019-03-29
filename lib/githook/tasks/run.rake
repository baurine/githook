desc 'Run hook tasks'
task :run do |_t|
  hook = ENV['HOOK']
  if hook
    Githook::Util.log_task(hook)
    Githook::Util.run_tasks(hook.to_sym)
  end
end
