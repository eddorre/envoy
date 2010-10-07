module Envoy
  class Git
    def self.current_branch
      `git symbolic-ref HEAD 2> /dev/null`.gsub('refs/heads/', '').delete("\n")
    end

    def self.changes(current_branch = 'master')
      %x[git log origin/#{current_branch}.. --pretty=oneline]
    end
  end
end