class Cleaner
  def warn_if_not_master
    if current_branch != "master"
      message = begin
        if current_branch != "HEAD"
          "You are NOT on branch master. Current branch: #{current_branch} \e[0m"
        else
          "You are not on a branch\e[0m"
        end
      end
      warn message
    end  
  end
  
  def warn(message)
    puts "\e[31mWARNING: #{message}"
    puts
  end
  
  def current_branch
    @current_branch ||= `git rev-parse --abbrev-ref HEAD`.chomp
  end
  
  def remotes
    @remotes ||= `git remote`.split("\n").map(&:strip)
  end
  
  def prune_remotes
    remotes.each do |remote|
      puts remote
      stale_branches = `git remote prune #{remote} --dry-run`
      unless stale_branches.empty?
        puts "pruning stale #{remote}-tracking branches"
        `git remote prune #{remote}`
      end
    end
  end
  
  def remote_branches 
    @remote_branches ||= `git branch -r --merged`.split("\n").map(&:strip).reject {
      |b| b =~ /\/(#{current_branch}|master|staging|production|HEAD)/
    }
  end

  def local_branches
    @local_branches ||= `git branch --merged`.gsub(/^\* /, '').split("\n").map(&:strip).reject {
      |b| b =~ /(#{current_branch}|master|staging|production|HEAD)/
    }
  end
  
  def check_merged_branches
    puts "Checking merged branches..."
    puts "---------------------------"

    if remote_branches.empty? && local_branches.empty?
      puts "No existing branches have been merged into #{current_branch}."
    else
      puts "This will remove the following branches:"
      puts "##### REMOTE BRANCH \e[32m"
      puts remote_branches
      puts "\e[0m##### LOCAL BRANCH \e[36m"
      puts local_branches
      puts "--------------"
      puts "\e[0m\e[33mPROCEED? (y/n)\e[0m"
      if gets.include?('y')
        # Remove remote branches
        remote_branches.each do |b|
          match = b.match /^([a-zA-Z]+)\/(.*)/ 
          `git push #{match[1]} --delete #{match[2]}`
        end
        # Remove local branches
        `git branch -d #{local_branches.join(' ')}`
      else
        puts "No branches removed."
      end
    end
  end
  
  def run
    prune_remotes
    check_merged_branches
  end
  
  def initialize(args)
    current_branch
    warn_if_not_master
  end
end
