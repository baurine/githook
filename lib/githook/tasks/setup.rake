desc 'setup hooks'
task :setup do |t|
  Githook::Util.log(t.name)

  # setup 1, check whether has '.git-hooks/hooks' and '.git' folder
  hooks_path = '.githook/hooks'
  unless Dir.exists?(hooks_path)
    puts "There isn't .git-hooks/hooks folder."
    exit 1
  end

  git_path = '.git'
  unless Dir.exists?(git_path)
    puts "There isn't .git folder."
    exit 1
  end

  # setup 2, backup hooks
  Rake::Task[:backup_hooks].invoke

  # setup 3, copy hooks to .git/hooks
  FileUtils.cp_r(hooks_path, git_path)
end

desc 'backup old hooks in .git/hooks'
task :backup_hooks do |t|
  Githook::Util.log(t.name)

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
task :clear_backup do |t|
  Githook::Util.log(t.name)

  backup = Dir.glob('.git/hooks/*.bak')
  Githook::Util.interactive_delete_files(backup, 'backup hooks')
end

desc 'clear all hooks (include backup) in .git/hooks'
task :clear => :clear_backup do |t|
  Githook::Util.log(t.name)

  hooks = Dir.glob('.git/hooks/*')
             .reject { |path| path.split('/').last.include?('.') }
  Githook::Util.interactive_delete_files(hooks, 'hooks')
end
