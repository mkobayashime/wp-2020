#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
cgi = CGI.new
require "securerandom"
require "sqlite3"
require "erb"

cookies = cgi.cookies

user_id = (cookies["user_id"][0] || "0").to_s
if user_id === "0" then
  uuid = SecureRandom.uuid
  user_id_cookie = CGI::Cookie.new("name" => "user_id", "value" => uuid)
  user_id = user_id_cookie.value[0]
end

print cgi.header("charset" => "utf-8", "cookie" => [user_id_cookie])

err = ""

begin
  my_themes = []
  all_themes = []

  SQLite3::Database.new("enquete_system.db") do |db|
    db.transaction() {
      db.execute("select * from themes where user_id = ?;", user_id) { |row|
        title = row[2].to_s.force_encoding("UTF-8")

        dom = <<~HTML
          <li>
            <a href="vote.rb?theme_id=#{row[0]}">#{title}</a> <a href="delete.rb?theme_id=#{row[0]}">削除</a>
          </li>
        HTML
        my_themes.push(dom)
      }
      db.execute("select * from themes;") { |row|
        title = row[2].to_s.force_encoding("UTF-8")

        dom = <<~HTML
          <li>
            <a href="vote.rb?theme_id=#{row[0]}">#{title}</a>
          </li>
        HTML
        all_themes.push(dom)
      }
    }
  end

  if my_themes.length === 0 then
    my_themes.push("投稿したテーマがありません")
  end
  if all_themes.length === 0 then
    all_themes.push("投稿されたテーマがありません")
  end

  erb = ERB.new(File.read("index.rhtml"))
  print erb.result(binding)
rescue => ex
  err = ex.message
  puts err
end