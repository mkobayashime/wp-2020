#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
cgi = CGI.new
require "sqlite3"
require "erb"

print cgi.header("text/html; charset=utf-8")

err = ""

theme_id = cgi.params["theme_id"][0]
if theme_id.empty? then
  err += "Error: theme_id not found<br>"
end

cookies = cgi.cookies
user_id = (cookies["user_id"][0] || "0").to_s
if user_id.empty? || user_id === "0" then
  err += "Error: ユーザー登録されていません<br>ホームを開いてからやり直してください<br>"
end

puts err

if err.empty? then
  begin
    title = ""
    choices = []

    SQLite3::Database.new("enquete_system.db") do |db|
      db.execute("select * from themes, choices where themes.theme_id = choices.theme_id and themes.theme_id = ?;", theme_id) { |row|
        title = row[2]
        choice_id = row[3]
        choice = row[5]
        html = <<~HTML
        <div>
          <input type="checkbox" name="choice" value="#{choice_id}" id="#{choice_id}">
          <label for="#{choice_id}">#{choice}</label>
        </div>
        HTML
        choices.push(html)
      }
    end

    erb = ERB.new(File.read("vote.rhtml"))
    print erb.result(binding)
  rescue => exception
    err += exception.message
    puts err
  end
end
