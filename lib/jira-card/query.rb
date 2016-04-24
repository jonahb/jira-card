module JIRACard
  class Query
    def execute(jira_client)
      raise NotImplementedError
    end
  end
end
