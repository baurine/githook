task :install do |t|
  # step 1, check whether Dir.pwd is in git repo root folder
  git_path = ".git"
  unless Dir.exists?(git_path)
    puts "It isn't in a git repo root folder."
    exit 1
  end

  # step 2, check whether '.githook' folder already exists
  githook_path = ".githook"
  if Dir.exists?(githook_path)
    print ".githook already exists, do you want to override it? [y/(n)]: "
    choice = STDIN.gets
    exit 0 if ["n", "N", "\n"].include?(choice[0])
    FileUtils.rm_r(githook_path)
  end

  # setup 3, copy templates to .githook
  templates_path = File.expand_path("../../templates", __FILE__)
  FileUtils.cp_r(templates_path, githook_path)
  puts "Create .githook folder."
end
