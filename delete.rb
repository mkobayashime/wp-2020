#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
cgi = CGI.new
require "sqlite3"
require "securerandom"
require "erb"

print cgi.header("text/html; charset=utf-8")

err = ""

theme_id = cgi.params["theme_id"][0]
if theme_id.empty? then
  err += "Error: theme_id not found<br>"
end

cookies = cgi.cookies
user_id = (cookies["user_id"][0] || "0").to_s
if user_id.empty? then
  err += "Error: Couldn't get user_id<br>"
end

if err.empty? then
  begin
    user_id_on_db = ""
    SQLite3::Database.new("enquete_system.db") do |db|
      db.transaction() {
        db.execute("select user_id from themes where theme_id = ? limit 1;", theme_id) { |row|
          user_id_on_db = row[0]
        }
      }
      if user_id === user_id_on_db then
        db.transaction() {
          db.execute("delete from themes where theme_id = ?;", theme_id)
          db.execute("delete from choices where theme_id = ?;", theme_id)
        }
      end
    end

    erb = ERB.new(File.read("delete.rhtml"))
    print erb.result(binding)
  rescue => exception
    err += exception.message
  end
end
