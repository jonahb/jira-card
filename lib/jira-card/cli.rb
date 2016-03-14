require 'highline'
require 'thor'
require 'yaml'

module JIRACard
  class CLI < Thor
    desc "my", "Prints the user's in-progress issues"
    option :number, type: :numeric, default: nil, aliases: %w{n}, desc: "Number of issues to print"
    option :uris, type: :boolean, default: false, aliases: %w{u}, desc: "Print URIs"
    def my
      issues = client.current_user_in_progress_issues

      if options[:number]
        issues = issues.take(options[:number])
      end

      issues.each do |issue|
        puts options[:uris] ? client.issue_uri(issue) : issue.key
      end
    end

    default_command :my

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

      Client.new config[:username], config[:password], config[:site]
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

      {
        username: username,
        password: password,
        site: site
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
  end
end

