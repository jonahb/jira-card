%w{
  cli
  query
  version
  queries/my
}.each do |file|
  require "jira-card/#{file}"
end
