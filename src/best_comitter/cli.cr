require "option_parser"

require "./version"
require "./config"
require "./counter/*"

module BestComitter
  class CLI
    def initialize
    end

    def run(args)
      begin
        run_with_args(args)
      rescue OptionParser::MissingOption
        puts "Missing arguments"
      end
    end

    private def run_with_args(args)
      days = 0

      parser = OptionParser.parse(args) do |parser|
        parser.banner = "
Usage:

  $ ./bin/best_comitter public --days 7
  Show Best OSS Comitter

  $ ./bin/best_comitter private --days 7
  Show Best Comitter
        "
        parser.on("-v", "--version", "Show version") { show_version }
        parser.on("-h", "--help", "Show help") { show_help(parser) }
        parser.on("-d DAYS", "--days DAYS", "Counting days") { |x| days = x.to_i }
      end

      config = load_config
      after = Time.now
      before = after - days.days
      github = GitHub::Simple::Client.new(
        access_token: config.github.access_token,
        auto_paginate: true
      )

      case args[0]?
      when "public"
        count_public(config, github, before, after)
      when "private"
        count_private
      else
        show_help(parser)
      end
    end

    def show_version
      puts "BestComitter v#{BestComitter::VERSION}"
    end

    def show_help(parser)
      puts parser
      puts
      exit
    end

    def count_public(config, github, before, after)
      counter = PublicCommitCounter.new(config, github)
      results = counter.count(before, after)

      puts "FROM: #{before}"
      puts "TO  : #{after}"
      puts

      results.each do |username, counts|
        count = counts.map { |k, v| v }.sum

        if count > 0
          puts "#{username}: #{count}"
          counts.each { |k, v| puts " - #{k}: #{v}" }
          puts
        end
      end
    end

    def count_private
      puts "Counting private repositories commits count ..."
    end

    private def load_config
      Config::Config.from_yaml_file("config.yml")
    end
  end
end
