# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"

## -- Config -- ##

posts_dir       = "_posts" # directory for blog files
new_post_ext    = "md"     # default new post file extension when using the new_post task
new_page_ext    = "md"     # default new page file extension when using the new_page task


#############################
# Create a new Post or Page #
#############################

DATE_FORMAT = "%Y-%m-%d"
TODAY       = Time.now.strftime(DATE_FORMAT)
BASE_TIME   = Time.new(2014,5,21)

# usage rake new_post
desc "Create a new post in #{posts_dir}"
task :new_post do |t, args|
  #タイトルは自動で作ることにする。
  display_name   = get_stdin('あなたの名前は?: ')
  privious_date  = process[:date].strftime(DATE_FORMAT)
  privious_times = process[:times]

  times = get_stdin("何回目のOkinawarb Meetupsに参加しましたか?(前回開催(#{privious_date}):#{privious_times}回): ")
  times = process[:times] if times.empty?

  git_checkout("#{TODAY}-no#{times}-#{display_name}")

  filename = "#{posts_dir}/#{TODAY}-no#{times}-#{display_name}.#{new_post_ext}"
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    #レイアウトの指定とか
    post.puts "---"
    post.puts "layout: default"
    post.puts "title: \"Okinawarb meetup! ##{times} でやったこと by #{display_name}\""
    post.puts "date: #{TODAY}"
    post.puts "categories: no#{times}"
    post.puts "---"
    #勝手に書いてほしいことをKPTに基いて書いてくれるといいなみたいな
    post.puts "## #{display_name}"
    post.puts "## やること宣言"
    post.puts "※[Okinawarb/meetups のissuesで書いたやること宣言](https://github.com/okinawarb/meetups/issues)のリンクをはってみましょう。"
    post.puts ""
    post.puts "## やったこと"
    post.puts "※やったことをかいていきましょう。"
    post.puts ""
    post.puts "## 振り返り"
    post.puts "### 良かったこと"
    post.puts "※今回の活動でよかったことを教えて下さい"
    post.puts ""
    post.puts "### ここは直した方がいいなぁと思ったこと"
    post.puts "※今回の活動でここは直したいなぁ、工夫したいなぁと思ったことを教えて下さい"
    post.puts ""
    post.puts "### 次回改善したいこと"
    post.puts "※次回参加するなら、こうしたい、試してみたいことがあれば共有しましょう！"
    post.puts ""
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def process
  process = (Time.now - BASE_TIME).div(24*60*60)
  if    process < 0
    times = 117
    date  = BASE_TIME
  elsif process > 0
    times = 117 + process.div(7)
    date  = BASE_TIME + 7 * process.div(7) * 24 * 60 * 60
  end
  {times:times, date: date }
end

def git_checkout(branch_name)
  `git checkout -b #{branch_name}`
end
