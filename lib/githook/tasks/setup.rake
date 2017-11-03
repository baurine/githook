desc 'setup hooks'
task :setup do
  # setup 1, check whether has '.githook/hooks' and '.git' folder
  hooks_path = '.githook/hooks'
  unless Dir.exists?(hooks_path)
    puts "There isn't a .githook/hooks folder."
    exit 1
  end

  git_path = '.git'
  unless Dir.exists?(git_path)
    puts "There isn't a .git folder."
    exit 1
  end

  # setup 2, backup hooks
  puts "Backup old hooks:"
  Rake::Task[:backup].invoke

  # setup 3, copy hooks to .git/hooks
  FileUtils.cp_r(hooks_path, git_path)
end

desc 'backup old hooks in .git/hooks'
task :backup do
  has_backup = false
  Dir.glob('.git/hooks/*').each do |path|
    file_name = path.split('/').last
    next if file_name.include?('.')

    appendix = ".#{Time.now.strftime("%Y%m%d%H%m%S")}.bak"
    puts "Backup old #{file_name} to #{file_name}#{appendix}"
    FileUtils.cp(path, "#{path}#{appendix}")
    has_backup = true
  end

  puts "you can run 'rake clear_backup' to delete these backup" if has_backup
end

desc 'clear backup hooks in .git/hooks'
task :clear_backup do
  backup = Dir.glob('.git/hooks/*.bak')
  Githook::Util.interactive_delete_files(backup, 'backup hooks')
end

# later I think we don't need to clear hooks, use disable/enable replace them
# desc 'clear all hooks (include backup) in .git/hooks'
# task :clear => :clear_backup do |t|
#   Githook::Util.log(t.name)

#   hooks = Dir.glob('.git/hooks/*')
#              .reject { |path| path.split('/').last.include?('.') }
#   Githook::Util.interactive_delete_files(hooks, 'hooks')
# end

ALL_HOOKS = %w(
  applypatch_msg
  pre_applypatch
  post_applypatch
  pre_commit
  prepare_commit_msg
  commit_msg
  post_commit
  pre_rebase
  post_checkout
  post_merge
  pre_receive
  post_receive
  update
  post_update
  pre_auto_gc
  post_rewrite
)

desc 'disable hooks: HOOKS=pre_commit,commit_msg githook disable'
task :disable do
  target_hooks = (ENV['HOOKS'] || '').split(',') || ALL_HOOKS
  target_hooks.each do |hook|
    hook_path = File.join('.git/hooks', hook.gsub('_', '-'))
    if File.file?(hook_path)
      disable_path = hook_path + '.disable'
      FileUtils.mv(hook_path, disable_path)
      puts "Disable #{hook} hook."
    else
      puts "#{hook} hook doesn't exist, skip."
    end
  end
end

desc 'enable hooks: HOOKS=pre_commit,commit_msg githook enable'
task :enable do
  target_hooks = (ENV['HOOKS'] || '').split(',') || ALL_HOOKS
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
