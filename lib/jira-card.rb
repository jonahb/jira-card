%w{
  cli
  query
  version
  queries/jql
  queries/key
  queries/my
}.each do |file|
  require "jira-card/#{file}"
end
