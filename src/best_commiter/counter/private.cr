require "github_simple"
require "../github"
require "./mixin"

module BestCommiter
  class PrivateCommitCounter
    include GitHub::EventType
    include CounterUtils

    def initialize(@config, @github)
    end

    def count(before, after)
      users = @config.users || [] of String
      repo_names = @config.repos || [] of String
      commits = repo_names.map { |name| commits_by_repo_name(name, before, after) }.flatten
      users.map { |user| {user, count_by_commits(user, commits)} }.to_h
    end

    protected def commits_by_repo_name(name, before, after)
      commits_by_repo_name(@github, name, before, after)
    end
  end
end