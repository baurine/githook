# we must be very careful to load outside ruby code
# because they are out of our control
# only load outside "*.rake" when there are ".git" and ".githook" folder, and target task isn't "install"
if Dir.exist?('.git') && Dir.exist?('.githook') && ARGV[0] != 'install'
  begin
    load '.githook/config.rb'
  rescue StandardError => e
    puts "Error: #{e.message} in .githook/config.rb"
    exit 1
  end
end
