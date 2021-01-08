#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
cgi = CGI.new
require "sqlite3"
require "securerandom"

print cgi.header("text/html; charset=utf-8")

title = cgi.params["title"][0]
ans1 = cgi.params["ans1"][0]
ans2 = cgi.params["ans2"][0]
ans3 = cgi.params["ans3"][0]

theme_id = SecureRandom.uuid
ans1_id = SecureRandom.uuid
ans2_id = SecureRandom.uuid
ans3_id = SecureRandom.uuid

cookies = cgi.cookies
user_id = (cookies["user_id"][0] || "0").to_s

if user_id === "0" then
  print <<~HTML
  <!DOCTYPE html>
  <html lang="jp">
  
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>未登録です</title>
    <link rel="stylesheet" href="global.css">
    <script>
      window.setTimeout(() => {
        window.location.href = "./index.rb"
      }, 3000)
    </script>
  </head>
  <body>
    <h1>ユーザー登録されていません</h1>
    <p>ホームを開いてからやり直してください</p>
    <div class="links">
      <div>
        <a href="index.rb">ホームに戻る</a>
      </div>
    </div>
  </body>
  HTML
else
  if title.empty? or ans1.empty? or ans2.empty? or ans3.empty? then
    print <<~HTML
  <!DOCTYPE html>
  <html lang="jp">
  
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>空欄があります</title>
    <link rel="stylesheet" href="global.css">
    <script>
      window.setTimeout(() => {
        window.location.href = "./index.rb"
      }, 3000)
    </script>
  </head>
  <body>
    <h1>空欄があります</h1>
    <p>やり直してください</p>
    <div class="links">
      <div>
        <a href="index.rb">ホームに戻る</a>
      </div>
    </div>
  </body>
  HTML
  else
    begin
      SQLite3::Database.new("enquete_system.db") do |db|
        db.transaction() {
          db.execute("insert into themes values(?, ?, ?);", theme_id, user_id, title)
          db.execute("insert into choices values(?, ?, ?);", ans1_id, theme_id, ans1)
          db.execute("insert into choices values(?, ?, ?);", ans2_id, theme_id, ans2)
          db.execute("insert into choices values(?, ?, ?);", ans3_id, theme_id, ans3)
        }
      end
    
      print <<~HTML
      <!DOCTYPE html>
      <html lang="jp">
      
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>投稿完了</title>
        <link rel="stylesheet" href="global.css">
      </head>
      <body>
        <h1>テーマの投稿が完了しました</h1>
        <div class="links">
          <div>
            <a href="index.rb">ホームに戻る</a>
          </div>
        </div>
      </body>
      HTML
    rescue => ex
      puts ex.message
      puts ex.backtrace
    end
  end
  
end