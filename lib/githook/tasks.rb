# load rake files from lib
rake_files_pattern = File.dirname(__FILE__) + "/tasks/**/*.rake"
# => gems/git-hook-0.1.1/lib/githook/tasks/**/*.rake
Dir.glob(rake_files_pattern).each { |r| load r }

# load rake files from outside project, defined by developer
# in case the outside rake file has some errors,
# not load them when target task is "install"
if ARGV[0] != "install"
  Dir.glob(".githook/tasks/**/*.rake").each { |r| load r }
end
