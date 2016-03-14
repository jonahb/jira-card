module JIRACard
  class Util
    def self.branch_name(issue)
      desc = issue.summary.downcase.split.join('-')
      "#{issue.key}-#{desc}"
    end
  end
end

