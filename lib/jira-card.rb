%w{
  cli
  client
  version
}.each do |file|
  require "jira-card/#{file}"
end
