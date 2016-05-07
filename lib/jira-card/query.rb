module JIRACard
  class Query
    attr_reader :index

    def initialize(index = nil)
      @index = index
    end

    def execute(jira_client)
      issues = do_execute(jira_client)

      if index
        issues[index, 1] || []
      else
        issues
      end
    end

    private

    def do_execute(jira_client)
      raise NotImplementedError
    end
  end
end
