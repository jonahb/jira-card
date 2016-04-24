%w{
  cli
  query
  version
  queries/key
  queries/my
}.each do |file|
  require "jira-card/#{file}"
end
