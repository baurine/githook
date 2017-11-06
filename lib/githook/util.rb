module Githook
  class Util
    def self.log_task(task_name)
      puts "[#{Time.now.strftime('%H:%m:%S')}] #{task_name.gsub('_', ' ')}"
    end

    def self.run_tasks(hook_stage)
      tasks = fetch(hook_stage, [])
      tasks.each do |task|
        if Rake::Task.task_defined?(task)
          Rake::Task[task].invoke
        else
          puts "#{task} task doesn't exist."
        end
      end
    end

    #######################################################

    def self.interactive_delete_files(path_arr, type)
      if path_arr.length == 0
        puts "There are no #{type}."
      else
        puts "There are following #{type}:"
        puts path_arr
        print "Are you sure want to delete all of them [(y)/n]: "
        # https://stackoverflow.com/a/40643667/2998877
        choice = STDIN.gets
        if ["Y", "y", "\n"].include?(choice[0])
          path_arr.each do |path|
            FileUtils.rm(path)
            puts "Delete #{path}"
          end
        end
      end
    end

    #######################################################

    # def self.enabled_hooks
    #   Dir.glob(".git/hooks/*")
    #      .map { |path| path.split("/").last }
    #      .reject { |name| name.include?(".") }
    #      .map { |name| name.gsub("-", "_") }
    # end

    # include enabled_hooks and disabled_hooks
    def self.all_hooks
      Dir.glob(".git/hooks/*")
         .map { |path| path.split("/").last }
         .select { |name| !name.include?(".") || name.include?(".disable") }
         .map { |name| name.gsub(".disable", "") }
         .uniq
         .map { |name| name.gsub("-", "_") }
    end

    #######################################################

    def self.commit_msg_file
      ".git/COMMIT_EDITMSG"
    end

    def self.branch_name
      `git symbolic-ref --short HEAD`.strip
    end

    def self.get_commit_msg(commit_msg_file)
      commit_msg = []
      # trim begining empty lines
      File.open(commit_msg_file, "r") do |f|
        f.readlines.each do |line|
          next if line[0] == "#"
          next if commit_msg.empty? && line.strip.empty?
          commit_msg << line
        end
      end
      # trim redundant tail empty lines
      unless commit_msg.empty?
        last_not_empty_line = 0
        commit_msg.each_with_index do |line, index|
          last_not_empty_line = index unless line.strip.empty?
        end
        commit_msg = commit_msg[0..last_not_empty_line]
      end
      # remove every line right blank space, include "\n"
      commit_msg.map(&:rstrip)
    end

    # check whether origin commit msg is empty
    def self.commit_msg_empty?(commit_msg_arr)
      commit_msg_arr.each do |line|
        return false unless line.strip.empty?
      end
      true
    end

    # default valid branch name: feature/24_add_enable_task
    # will generate commit message: FEATURE #24 - Add enable task
    DEF_BRANCH_NAME_REG = /^(feature|bug|hotfix|misc|refactor)\/(\d*)?(\w*)/
    # generate pre msg according branch name
    # why do I pass branch_name as a parameter, not implement it inside the gen_pre_msg,
    # because this is easy to test, it a kind of inject dependency thinking.
    def self.gen_pre_msg(branch_name)
      match_group = DEF_BRANCH_NAME_REG.match(branch_name)
      if match_group
        issue_type = match_group[1].upcase
        issue_num = match_group[2]
        issue_content = match_group[3]

        issue_type = "BUG" if issue_type == "HOTFIX"
        issue_num = " \##{issue_num}" unless issue_num.empty?
        issue_content = issue_content.tr("_", " ").strip.capitalize

        "#{issue_type}#{issue_num} - #{issue_content}"
      else
        "MISC - "
      end
    end

    # write the pre msg at the begining of commit_msg_file
    def self.prefill_msg(commit_msg_file, pre_msg)
      File.open(commit_msg_file, "r+") do |f|
        ori_content = f.read
        f.seek(0, IO::SEEK_SET)
        f.puts pre_msg
        f.puts ori_content
      end
    end

    DEF_MSG_SUMMARY_REG = /^(FEATURE|BUG|MISC|REFACTOR)(\s#\d+)* - ([A-Z].*)[^.]$/
    DEF_MSG_SUMMARY_FORMAT = "FEAUTER|BUG|MISC|REFACTOR #issue_num - Summary"
    DEF_MSG_BODY_REG = /^- ([a-z].*)[^.]$/
    DEF_MSG_BODY_FORMAT = "- detail"
    def self.check_msg_format?(commit_msg_arr)
      summary = commit_msg_arr[0] || ""
      second_line = commit_msg_arr[1] || ""
      body = commit_msg_arr[2..-1] || []

      valid = summary.start_with?("Merge branch") || DEF_MSG_SUMMARY_REG.match(summary)
      unless valid
        puts "Commit message summary \"#{summary}\" format isn't correct."
        puts "Expected format: \"#{DEF_MSG_SUMMARY_FORMAT}\""
        return false
      end

      valid = second_line.strip.empty?
      unless valid
        puts "Commit message the first line after summary should be blank."
        return false
      end

      body.each do |line|
        unless DEF_MSG_BODY_REG.match(line)
          puts "Commit message body line \"#{line}\" format isn't correct."
          puts "Expected format: \"#{DEF_MSG_BODY_FORMAT}\""
          return false
        end
      end
      true
    end
  end
end
