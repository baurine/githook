namespace :pre_commit do
  desc 'check ruby code style by rubocop'
  task :rubocop do |t|
    Githook::Util.log(t.name)
    exit 1 unless system("bundle exec rubocop")
  end

  desc 'test ruby code by rspec'
  task :rspec do |t|
    Githook::Util.log(t.name)
    exit 1 unless system("bundle exec rspec")
  end

  desc 'check java code style by checkstyle'
  task :checkstyle do |t|
    Githook::Util.log(t.name)
    exit 1 unless system("./gradlew checkstyle")
  end
end

desc 'run all pre-commit hook tasks'
task :pre_commit do |t|
  Githook::Util.log(t.name)
  Githook::Util.run_tasks(t.name.to_sym)
end
