module JIRACard
  class MyQuery < Query
    def execute(jira_client)
      jira_client.Issue.jql "assignee = currentUser() AND status = 'In Progress' ORDER BY key"
    end
  end
end
