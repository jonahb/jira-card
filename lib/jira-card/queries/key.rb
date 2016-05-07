module JIRACard
  class KeyQuery < Query
    def initialize(key, index = nil)
      super(index)
      @key = key
    end

    def single?
      true
    end

    private

    def do_execute(jira_client)
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
