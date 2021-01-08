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

puts err

if err.empty? then
  begin
    title = ""
    choices = []

    sql = <<~SQL
      select t.theme_id, t.title, c.choice_id, count(c.choice_id), c.theme_id, c.text, v.theme_id, v.choice_id 
      from themes t, votes v, choices c 
      where t.theme_id = c.theme_id and c.choice_id = v.choice_id 
      and t.theme_id = ?
      group by c.choice_id order by count(c.choice_id) desc;
    SQL

    SQLite3::Database.new("enquete_system.db") do |db|
      db.execute(sql, theme_id) { |row|
        title = row[1]
        count = row[3]
        text = row[5]

        dom = "<li>#{text}: #{count}票</li>"
        choices.push(dom)
      }
    end

  rescue => exception
    err += exception.message
    puts err
  end
end

erb = ERB.new(File.read("result.rhtml"))
print erb.result(binding)