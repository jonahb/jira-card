module JIRACard
  class Util
    def self.branch_name(issue, prefix: nil)
      desc = issue.summary.downcase.split.join('-')
      [prefix, issue.key, desc].reject(&:blank?).join("-")
    end
  end
end

