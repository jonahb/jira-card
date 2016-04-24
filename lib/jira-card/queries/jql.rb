module JIRACard
  class JQLQuery < Query
    def initialize(jql)
      @jql = jql
    end

    def execute(jira_client)
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
