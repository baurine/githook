namespace :prepare_commit_msg do
  # generate pre msg according branch name
  # why do I pass branch_name as a parameter, not implement it inside the gen_pre_msg_for_ekohe_branch,
  # because this is easy to test, it a kind of inject dependency thinking.
  def gen_pre_msg_for_ekohe_branch(branch_name)
    # default ekohe valid branch name: feature/24_add_enable_task
    # will generate commit message: FEATURE #24 - Add enable task
    default_ekohe_branch_name_reg = /^(feature|bug|hotfix|misc|refactor)\/(\d*)?(\w*)/

    match_group = default_ekohe_branch_name_reg.match(branch_name)
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

  desc "Prepare commit msg for ekohe branch"
  task :prepare_for_ekohe_branch do |t|
    Githook::Util.log_task(t.name)

    commit_msg_file = Githook::Util.commit_msg_file
    commit_msg = Githook::Util.get_commit_msg(commit_msg_file)
    if Githook::Util.commit_msg_empty?(commit_msg)
      branch_name = Githook::Util.branch_name
      pre_msg = gen_pre_msg_for_ekohe_branch(branch_name)
      puts "pre-msg:"
      puts pre_msg
      Githook::Util.prefill_msg(commit_msg_file, pre_msg)
    end
  end
end
