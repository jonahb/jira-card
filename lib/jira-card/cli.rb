require 'highline'
require 'thor'
require 'yaml'

module JIRACard
  class CLI < Thor
    desc "key [options]", "Prints issue keys"
    long_desc "By default, prints the key of the first issue assigned to the current user"
    option :all, type: :boolean, default: false, aliases: %w{a}, desc: "Print keys for all issues"
    def key
      each_issue(options) do |issue|
        puts issue.key
      end
    end

    desc "uri [options]", "Prints issue URIs"
    long_desc "By default, prints the URI of the first issue assigned to the current user"
    option :all, type: :boolean, default: false, aliases: %w{a}, desc: "Print URIs for all issues"
    def uri
      each_issue(options) do |issue|
        puts client.issue_uri(issue)
      end
    end

    desc "branch [options]", "Prints suggested branch names"
    option :all, type: :boolean, default: false, aliases: %w{a}, desc: "Prints branch names based on issue title and key"
    def branch
      each_issue(options) do |issue|
        puts Util.branch_name(issue)
      end
    end

    default_command :key

    private

    def client
      @client ||= new_client
    end

    def new_client
      config = saved_config

      unless config
        config = collect_config
        save_config config
      end

      Client.new config[:username], config[:password], config[:site], config[:context_path]
    end

    def saved_config
      begin
        YAML.load_file config_file
      rescue StandardError
        nil
      end
    end

    def collect_config
      highline = HighLine.new

      username = highline.ask("Username (john.doe): ")
      password = highline.ask("Password: ") { |q| q.echo = false }
      site = highline.ask("URL (https://company.atlassian.net): ")
      context_path = highline.ask("Context path (empty for sites on atlassian.net): ")

      {
        username: username,
        password: password,
        site: site,
        context_path: context_path
      }
    end

    def save_config(config)
      File.open(config_file, "w", 0600) do |io|
        YAML.dump config, io
      end
    end

    def config_file
      File.expand_path "~/.jira-card"
    end

    def each_issue(options, &block)
      client.current_user_in_progress_issues.each &block
    end
  end
end

