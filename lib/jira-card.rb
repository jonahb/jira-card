%w{
  cli
  version
}.each do |file|
  require "jira-card/#{file}"
end
