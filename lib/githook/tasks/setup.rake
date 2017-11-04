desc 'Check whether .githook/hooks folder exists'
task :check_githook_folder do
  hooks_path = '.githook/hooks'
  unless Dir.exists?(hooks_path)
    puts "There isn't a .githook/hooks folder."
    exit 1
  end
end

desc 'Check whether .git/hooks folder exists'
task :check_git_folder do
  git_path = '.git/hooks'
  unless Dir.exists?(git_path)
    puts "There isn't a .git/hooks folder."
    exit 1
  end
end

#################################################################

desc 'Setup hooks'
task :setup => [:check_githook_folder, :check_git_folder] do
  # setup 1, check whether has '.githook/hooks' and '.git' folder
  # => [:check_githook_folder, :check_git_folder]

  # setup 2, backup hooks
  puts "Backup old hooks:"
  Rake::Task[:backup].invoke

  # setup 3, copy hooks to .git/hooks
  FileUtils.cp_r('.githook/hooks', '.git')
end

desc 'Backup old hooks in .git/hooks'
task :backup => :check_git_folder do
  has_backup = false
  Dir.glob('.git/hooks/*').each do |path|
    file_name = path.split('/').last
    next if file_name.include?('.')

    appendix = ".#{Time.now.strftime("%Y%m%d%H%m%S")}.bak"
    puts "Backup old #{file_name} to #{file_name}#{appendix}"
    FileUtils.cp(path, "#{path}#{appendix}")
    has_backup = true
  end

  puts "You can run 'githook clearup' to delete these backup." if has_backup
end

desc 'Clear backup hooks in .git/hooks'
task :clearup => :check_git_folder do
  backup = Dir.glob('.git/hooks/*.bak')
  Githook::Util.interactive_delete_files(backup, 'backup hooks')
end

# later I think we don't need to clear hooks, use disable/enable replace them
# desc 'clear all hooks (include backup) in .git/hooks'
# task :clear => :clearup do |t|
#   Githook::Util.log_task(t.name)

#   hooks = Dir.glob('.git/hooks/*')
#              .reject { |path| path.split('/').last.include?('.') }
#   Githook::Util.interactive_delete_files(hooks, 'hooks')
# end

# all hooks
# https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
# ALL_HOOKS = %w(
#   pre_commit
#   prepare_commit_msg
#   commit_msg
#   post_commit
#   pre_rebase
#   post_checkout
#   post_merge
#   pre_push
#   applypatch_msg
#   pre_applypatch
#   post_applypatch
#   pre_receive
#   post_receive
#   update
#   post_update
# )

desc 'Disable hooks: [HOOKS=pre_commit,commit_msg] githook disable'
task :disable => :check_git_folder do
  target_hooks = (ENV['HOOKS'] || '').split(',')
  target_hooks = Githook::Util.all_hooks if target_hooks.empty?

  target_hooks.each do |hook|
    hook_path = File.join('.git/hooks', hook.gsub('_', '-'))
    disable_path = hook_path + '.disable'
    if File.file?(hook_path)
      FileUtils.mv(hook_path, disable_path)
      puts "Disable #{hook} hook."
    elsif File.file?(disable_path)
      puts "#{hook} is already disabled, skip."
    else
      puts "#{hook} hook doesn't exist, skip."
    end
  end
end

desc 'Enable hooks: [HOOKS=pre_commit,commit_msg] githook enable'
task :enable => :check_git_folder do
  target_hooks = (ENV['HOOKS'] || '').split(',')
  target_hooks = Githook::Util.all_hooks if target_hooks.empty?

  target_hooks.each do |hook|
    hook_path = File.join('.git/hooks', hook.gsub('_', '-'))
    disable_path = hook_path + '.disable'
    if File.file?(hook_path)
      puts "#{hook} hook is arleady enabled, skip."
    elsif File.file?(disable_path)
      FileUtils.mv(disable_path, hook_path)
      puts "Enable #{hook} hook."
    else
      puts "#{hook} hook doesn't exist, skip."
    end
  end
end

desc 'List all hooks'
task :list => :check_git_folder do
  enabled_hooks = []
  disabled_hooks = []
  all_hooks = Githook::Util.all_hooks
  all_hooks.each do |hook|
    hook_path = File.join('.git/hooks', hook.gsub('_', '-'))
    disable_path = hook_path + '.disable'
    if File.file?(hook_path)
      enabled_hooks << hook
    elsif File.file?(disable_path)
      disabled_hooks << hook
    end
  end
  puts "Enabled hooks:"
  enabled_hooks.each { |h| puts "  * #{h}" }
  puts "Disabled hooks:"
  disabled_hooks.each { |h| puts "  * #{h}" }
end

desc 'Version'
task :version do
  puts Githook::VERSION
end

TASKS_NAME = %w(
  install
  setup
  backup
  clearup
  disable
  enable
  list
  version
  help
)
desc 'Help'
task :help do
  puts
  puts "Usage: githook task_name"
  puts
  puts "task_name:"
  TASKS_NAME.each do |task_name|
    task = Rake::Task[task_name]
    puts "  #{task_name.ljust(8)} -- #{task.comment}"
  end
end
