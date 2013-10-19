#!/usr/bin/env ruby

current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
if current_branch != "master"
  if current_branch != "HEAD"
    puts "\e[31mWARNING: You are NOT on branch master. Current branch: #{current_branch} \e[0m"
  else
    puts "\e[31mWARNING: You are not on a branch\e[0m"
  end
  puts
end

remote = `git remote`.
  split("\n").
  map(&:strip)

remote.each do |remote|
  stale_branches = `git remote prune #{remote} --dry-run`
  unless stale_branches.empty?
    puts "pruning stale #{remote}-tracking branches"
    `git remote prune #{remote}`
  end
end

puts "Checking merged branches..."
puts "---------------------------"
remote_branches= `git branch -r --merged`.
  split("\n").
  map(&:strip).
  reject {|b| b =~ /\/(#{current_branch}|master|staging|production|HEAD)/}

local_branches= `git branch --merged`.
  gsub(/^\* /, '').
  split("\n").
  map(&:strip).
  reject {|b| b =~ /(#{current_branch}|master|staging|production|HEAD)/}

if remote_branches.empty? && local_branches.empty?
  puts "No existing branches have been merged into #{current_branch}."
else
  puts "This will remove the following branches:"
  puts "##### REMOTE BRANCH \e[32m"
  puts remote_branches.join("\n")
  puts "\e[0m##### LOCAL BRANCH \e[36m"
  puts local_branches.join("\n")
  puts "--------------"
  puts "\e[0m\e[33mPROCEED? (y/n)\e[0m"
  if gets.include?("y")
    
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