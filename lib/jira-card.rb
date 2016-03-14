%w{
  cli
  client
  util
  version
}.each do |file|
  require "jira-card/#{file}"
end
