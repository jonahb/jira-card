module JIRACard
  class KeyQuery < Query
    def initialize(key)
      @key = key
    end

    def execute(jira_client)
      begin
        issue = jira_client.Issue.find(@key)
      rescue JIRA::HTTPError => error
        if error.code == "404"
          return []
        else
          raise
        end
      end

      [issue]
    end
  end
end
