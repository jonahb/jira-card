module JIRACard
  class MyQuery < Query
    def initialize(index = nil)
      super(index)
      @inner = JQLQuery.new("assignee = currentUser() AND status = 'In Progress' ORDER BY key")
    end

    private

    def do_execute(jira_client)
      @inner.execute jira_client
    end
  end
end
