require 'cgi'
require 'fileutils'
require 'jira'
require 'launchy'
require 'thor'
require 'yaml'

module JIRACard
  class CLI < Thor
    include Thor::Actions

    class << self
      def query_options
        option :jql, type: :string, aliases: :j, banner: "<jql>"
        option :key, type: :string, aliases: :k, banner: "<issue key>"
        option :my, type: :boolean, aliases: :m
      end
    end

    desc "ls [INDEX]", "Prints issues"
    query_options
    def ls(index = nil)
      index = index && index.to_i

      each_issue(options, index) do |issue|
        attrs = [
          issue.key,
          issue.issuetype.name,
          issue.summary
        ]

        puts attrs.join("\t")
      end
    end

    desc "key [INDEX]", "Prints issue keys"
    query_options
    def key(index = nil)
      index = index && index.to_i

      each_issue(options, index) do |issue|
        puts issue.key
      end
    end

    desc "uri [INDEX]", "Prints issue URIs"
    query_options
    map url: :uri
    def uri(index = nil)
      index = index && index.to_i

      each_issue(options, index) do |issue|
        puts issue_uri(issue)
      end
    end

    desc "branch [INDEX]", "Prints suggested branch names"
    query_options
    def branch(index = nil)
      index = index && index.to_i

      each_issue(options, index) do |issue|
        puts branch_name(issue)
      end
    end

    desc "open [INDEX]", "Opens issues in a browser"
    query_options
    def open(index = nil)
      index = index && index.to_i

      each_issue(options, index) do |issue|
        Launchy.open issue_uri(issue)
      end
    end

    default_command :ls

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
      JIRA::Client.new username: config[:username],
        password: config[:password],
        site: config[:site],
        context_path: config[:context_path],
        auth_type: :basic,
        read_timeout: 120
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
      username = ask("Username (john.doe):")
      password = ask("Password: ", echo: false)
      print "\n"
      site = ask("JIRA Site URL (https://company.atlassian.net): ")
      context_path = ask("Context path (empty for sites on atlassian.net): ")
      initials = ask("Your initials (for branch prefixes): ")

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

    def each_issue(options, index, &block)
      issues = query(options).execute(client)

      if index
        issues = issues[index, 1] || []
      end

      issues.each &block
    end

    def query(options)
      if options[:jql]
        JQLQuery.new options[:jql]
      elsif options[:key]
        KeyQuery.new options[:key]
      elsif options[:my]
        MyQuery.new
      else
        default_query
      end
    end

    def default_query
      MyQuery.new
    end

    def issue_uri(issue)
      parts = [
        client.options[:site],
        client.options[:context_path],
        'browse',
        CGI.escape(issue.key)
      ]

      parts.reject(&:blank?).join '/'
    end
  end
end

