module Githook
  class Util
    def self.log(task_name)
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

    # check whether origin commit msg is empty
    def self.commit_msg_empty?(commit_msg_file)
      File.open(commit_msg_file, 'r') do |f|
        f.readlines.each do |line|
          strip_line = line.strip
          return false if (!strip_line.empty? && !strip_line.start_with?('#'))
        end
      end
      true
    end

    BRANCH_NAME_REG = /^(feature|bug|hotfix|misc|refactor)\/(\d*)?(\w*)/
    # generate pre msg according branch name
    def self.gen_pre_msg(branch_name)
      match_group = BRANCH_NAME_REG.match(branch_name)
      if match_group
        issue_type = match_group[1].upcase
        issue_num = match_group[2]
        issue_content = match_group[3]

        issue_type = 'BUG' if issue_type == 'HOTFIX'
        issue_num = " \##{issue_num}" unless issue_num.empty?
        issue_content = issue_content.tr('_', ' ').strip.capitalize

        "#{issue_type}#{issue_num} - #{issue_content}"
      else
        'MISC - '
      end
    end

    # write the pre msg at the begining of commit_msg_file
    def self.prefill_msg(commit_msg_file, pre_msg)
      File.open(commit_msg_file, 'r+') do |f|
        ori_content = f.read
        f.seek(0, IO::SEEK_SET)
        f.puts pre_msg
        f.puts ori_content
      end
    end

    def self.get_commit_msg(commit_msg_file)
      commit_msg = ''
      File.open(commit_msg_file, 'r') do |f|
        f.readlines.each do |line|
          strip_line = line.strip
          if !strip_line.empty? && !strip_line.start_with?('#')
            commit_msg = line
            break
          end
        end
      end
      commit_msg
    end

    MSG_FORMAT_REG = /^(FEATURE|BUG|MISC|REFACTOR)(\s#\d+)* - ([A-Z].*)/
    # check commit msg style
    def self.expected_msg_format?(commit_msg)
      commit_msg.start_with?('Merge branch') || MSG_FORMAT_REG.match(commit_msg)
    end
  end
end
