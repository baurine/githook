# load rake files from lib
rake_files_pattern = File.dirname(__FILE__) + "/tasks/**/*.rake"
# => gems/git-hook-0.1.1/lib/githook/tasks/**/*.rake
Dir.glob(rake_files_pattern).each { |r| load r }

# we must be very careful to load outside ruby code
# because they are out of our control
# only load outside "*.rake" when there are ".git" and ".githook" folder, and target task isn't "install"
if Dir.exist?('.git') && Dir.exist?('.githook') && ARGV[0] != "install"
  Dir.glob(".githook/tasks/**/*.rake").each do |rake|
    begin
      load rake
    rescue => e
      puts "Error: #{e.message} in #{rake}"
      exit 1
    end
  end
end
