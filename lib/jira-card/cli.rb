require 'thor'
require 'yaml'

module JIRACard
  class CLI < Thor
    desc "my", "Prints the keys of the current user's in-progress issues"
    option :number, type: :numeric, default: nil, aliases: %w{n}, desc: "Number of keys to print"
    def my
      issues = client.current_user_in_progress_issues

      if options[:number]
        issues = issues.take(options[:number])
      end

      issues.each do |issue|
        puts issue.key
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
      $stdout.print "Username: "
      username = $stdin.readline.chomp

      $stdout.print "Password: "
      password = $stdin.readline.chomp

      $stdout.print "URL (https://company.atlassian.net): "
      site = $stdin.readline.chomp

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

