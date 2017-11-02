rake_files_pattern = File.dirname(__FILE__) + "/tasks/**/*.rake"
# => gems/git-hook-0.1.1/lib/githook/tasks/**/*.rake
Dir.glob(rake_files_pattern).each { |r| load r }
