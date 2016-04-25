module JIRACard
  class MyQuery < Query
    def initialize
      @inner = JQLQuery.new("assignee = currentUser() AND status = 'In Progress' ORDER BY key")
    end

    def execute(jira_client)
      @inner.execute jira_client
    end
  end
end
