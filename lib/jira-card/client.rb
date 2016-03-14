require 'jira'

module JIRACard
  class Client
    def initialize(username, password, site)
      opts = {
        username: username,
        password: password,
        site: site,
        auth_type: :basic,
        read_timeout: 120,
        context_path: ''
      }

      @client = JIRA::Client.new(opts)
    end

    def current_user_in_progress_issues
      jql = "assignee = currentUser() AND status = 'In Progress'"
      @client.Issue.jql jql
    end
  end
end

