module JIRACard
  class JQLQuery < Query
    def initialize(jql, index = nil)
      super(index)
      @jql = jql
    end

    private

    def do_execute(jira_client)
      begin
        jira_client.Issue.jql @jql
      rescue JIRA::HTTPError => error
        if error.code == "400"
          raise ArgumentError, "Bad JQL"
        else
          raise
        end
      end
    end
  end
end
