require 'fileutils'
require 'highline'
require 'thor'
require 'yaml'

module JIRACard
  class CLI < Thor
    desc "ls [options]", "Prints issues"
    def ls
      each_issue(options) do |issue|
        attrs = [
          issue.key,
          issue.issuetype.name,
          issue.summary
        ]

        puts attrs.join("\t")
      end
    end

    desc "key [options]", "Prints issue keys"
    def key
      each_issue(options) do |issue|
        puts issue.key
      end
    end

    desc "uri [options]", "Prints issue URIs"
    def uri
      each_issue(options) do |issue|
        puts client.issue_uri(issue)
      end
    end

    desc "branch [options]", "Prints suggested branch names"
    def branch
      each_issue(options) do |issue|
        puts branch_name(issue)
      end
    end

    default_command :key

    private

    def client
      @client ||= new_client
    end

    def config
      @config ||= new_config
    end

    def issue_prefixes
      @issue_prefixes ||= saved_issue_prefixes
    end

    def issue_prefix(issue)
      issue_prefixes && issue_prefixes[issue.issuetype.id]
    end

    def branch_name(issue)
      prefix = [issue_prefix(issue), config[:initials]].reject(&:blank?).join('/')
      desc = issue.summary.downcase.split.join('-')
      [prefix, issue.key, desc].reject(&:blank?).join("-")
    end

    def new_client
      Client.new config[:username], config[:password], config[:site], config[:context_path]
    end

    def new_config
      config = saved_config

      unless config
        config = collect_config
        save_config config
      end

      config
    end

    def saved_config
      begin
        YAML.load_file config_file
      rescue StandardError
        nil
      end
    end

    def saved_issue_prefixes
      begin
        YAML.load_file issue_prefixes_file
      rescue StandardError
        nil
      end
    end

    def collect_config
      highline = HighLine.new

      username = highline.ask("Username (john.doe): ")
      password = highline.ask("Password: ") { |q| q.echo = false }
      site = highline.ask("JIRA Site URL (https://company.atlassian.net): ")
      context_path = highline.ask("Context path (empty for sites on atlassian.net): ")
      initials = highline.ask("Your initials (for branch prefixes): ")

      {
        username: username,
        password: password,
        site: site,
        context_path: context_path,
        initials: initials
      }
    end

    def save_config(config)
      FileUtils.mkdir_p config_dir

      File.open(config_file, "w", 0600) do |io|
        YAML.dump config, io
      end
    end

    def config_dir
      File.expand_path "~/.jira-card"
    end

    def config_file
      File.join config_dir, "config.yml"
    end

    def issue_prefixes_file
      File.join config_dir, "issue_prefixes.yml"
    end

    def each_issue(options, &block)
      client.current_user_in_progress_issues.each &block
    end
  end
end

