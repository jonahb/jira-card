require 'jira'
require 'cgi'

module JIRACard
  class Client
    def initialize(username, password, site, context_path)
      opts = {
        username: username,
        password: password,
        site: site,
        auth_type: :basic,
        read_timeout: 120,
        context_path: context_path
      }

      @client = JIRA::Client.new(opts)
    end

    def current_user_in_progress_issues
      jql = "assignee = currentUser() AND status = 'In Progress'"
      @client.Issue.jql jql
    end

    def issue_uri(issue)
      parts = [
        @client.options[:site],
        @client.options[:context_path],
        'browse',
        CGI.escape(issue.key)
      ]

      parts.reject(&:blank?).join '/'
    end
  end
end

