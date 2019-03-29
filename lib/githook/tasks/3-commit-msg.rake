namespace :commit_msg do
  def check_msg_for_ekohe_format?(commit_msg_arr)
    def_ekohe_msg_summary_reg = /^(FEATURE|BUG|MISC|REFACTOR)(\s#\d+)* - ([A-Z].*)[^.]$/
    def_ekohe_msg_format = 'FEAUTER|BUG|MISC|REFACTOR #issue_num - Summary'
    def_ekohe_body_reg = /^- ([a-z].*)[^.]$/
    def_ekohe_body_format = '- detail'

    summary = commit_msg_arr[0] || ''
    second_line = commit_msg_arr[1] || ''
    body = commit_msg_arr[2..-1] || []

    valid = summary.start_with?('Merge branch') || def_ekohe_msg_summary_reg.match(summary)
    unless valid
      puts "Commit message summary \"#{summary}\" format isn't correct."
      puts "Expected format: \"#{def_ekohe_msg_format}\""
      return false
    end

    valid = second_line.strip.empty?
    unless valid
      puts 'Commit message the first line after summary should be blank.'
      return false
    end

    body.each do |line|
      next if def_ekohe_body_reg.match(line)
      puts "Commit message body line \"#{line}\" format isn't correct."
      puts "Expected format: \"#{def_ekohe_body_format}\""
      return false
    end
    true
  end

  desc 'Check commit msg style for ekohe format'
  task :check_msg_for_ekohe_format do |t|
    Githook::Util.log_task(t.name)

    commit_msg_file = Githook::Util.commit_msg_file
    commit_msg = Githook::Util.get_commit_msg(commit_msg_file)
    puts 'commit-msg:'
    puts commit_msg.join("\n")

    # can't use return in block
    # can't "exit 0" in advance, else will abort later tasks
    # but we can "exit 1" in advance
    exit 1 unless check_msg_for_ekohe_format?(commit_msg)
  end
end
