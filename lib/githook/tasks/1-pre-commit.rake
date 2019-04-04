namespace :pre_commit do
  desc 'Check ruby code style by rubocop'
  task :rubocop do |t|
    Githook::Util.log_task(t.name)
    changed_ruby_files = Githook::Util.changed_ruby_files
    exit 0 if changed_ruby_files.empty?
    exit 1 unless system("bundle exec rubocop --force-exclusion #{changed_ruby_files}")
  end

  desc 'Test ruby code by rspec'
  task :rspec do |t|
    Githook::Util.log_task(t.name)
    exit 1 unless system('bundle exec rspec')
  end

  desc 'Check java code style by checkstyle'
  task :checkstyle do |t|
    Githook::Util.log_task(t.name)
    exit 1 unless system('./gradlew checkstyle')
  end
end
