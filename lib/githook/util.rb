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
        print "Are you sure want to delete all of them [y/(n)]: "
        # https://stackoverflow.com/a/40643667/2998877
        choice = STDIN.gets
        return if ["N", "n", "\n"].include?(choice[0])

        path_arr.each do |path|
          FileUtils.rm(path)
          puts "Delete #{path}"
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

    # write the pre msg at the begining of commit_msg_file
    def self.prefill_msg(commit_msg_file, pre_msg)
      File.open(commit_msg_file, "r+") do |f|
        ori_content = f.read
        f.seek(0, IO::SEEK_SET)
        f.puts pre_msg
        f.puts ori_content
      end
    end
  end
end
