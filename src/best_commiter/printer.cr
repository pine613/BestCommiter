require "./models/period"

module BestCommiter
  class Printer
    def initialize(@period : Models::Period, @sort_order : Models::SortOrder)
    end

    def run(counter)
      results = counter.run(@period)
      sorted_results = sort_users(results)

      puts
      puts counter.title
      puts
      puts "FROM: #{@period.before}"
      puts "TO  : #{@period.after}"
      puts

      sorted_results.each do |result|
        username = result.name
        count = result.sum

        if count > 0
          puts "#{username}: #{count}"
          result.repos.each { |repo| puts " - #{repo.name}: #{repo.count}" }
          puts
        end
      end
    end

    private def sort_users(users : Array(Models::User)) : Array(Models::User)
      case @sort_order
      when Models::SortOrder::Name
        users.sort { |a, b| a.name <=> b.name }
      when Models::SortOrder::Count
        users.sort_by { |user| user.sum }.reverse
      else
        [] of Models::User
      end
    end
  end
end
