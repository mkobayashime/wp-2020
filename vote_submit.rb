#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
cgi = CGI.new
require "sqlite3"
require "erb"

print cgi.header("text/html; charset=utf-8")

err = ""
link_to_result_page = ""

choice_ids = cgi.params["choice"]
# choice_ids = []
if choice_ids.length === 0 then
  err += "Error: 何も選択されていません<br>"
end

theme_id = cgi.params["theme_id"][0]
# theme_id = ""
if theme_id.empty? then
  err += "Error: theme_id not found<br>"
end

cookies = cgi.cookies
user_id = (cookies["user_id"][0] || "0").to_s
if user_id.empty? || user_id === "0" then
  err += "Error: ユーザー登録されていません<br>ホームを開いてからやり直してください<br>"
end

if err.empty? then
  begin
    SQLite3::Database.new("enquete_system.db") do |db|
      db.transaction() {
        choice_ids.each { |choice_id|
          db.execute("insert into votes (theme_id, choice_id, user_id) values (?, ?, ?);", theme_id, choice_id, user_id)
        }
      }
    end
    
    link_to_result_page = <<~HTML
    <div>
      <a href="result.rb?theme_id=#{theme_id}">結果を見る</a>
    </div>
    HTML
  rescue => exception
    err += exception.message
  end
end

erb = ERB.new(File.read("vote_submit.rhtml"))
print erb.result(binding)