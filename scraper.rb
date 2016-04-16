#!/usr/bin/env ruby

require 'nokogiri'
require 'json'
require 'open-uri'
require 'sqlite3'
require 'pp'

class Repo
  def initialize(full_name, options = {})
    @full_name = full_name
    @owner_login = /\w+/.match(full_name)
    @name = /\/(\w+)/.match(full_name)
    @html_url = 'https://github.com/' + full_name
    @api_url = 'https://api.github.com/repos/' + full_name
    rate_limited = JSON.parse(open('https://api.github.com/rate_limit', http_basic_authentication: ['nloveladyallen', 'ked6tAy1Che7He']).read)['resources']['core']['remaining'] == 0
    info unless rate_limited
  end

  def info
    # CONTAINS GITHUB PASSWORD, DO NOT POST TO GITHUB AS IS
    @api_hash = JSON.parse(open(@api_url, http_basic_authentication: ['nloveladyallen', 'ked6tAy1Che7He']).read)
    @api_arr = []
    @api_hash.each do |p|
      @api_arr.push(p[1])
    end
    # p @api_arr
  end

  attr_reader :api_hash, :api_arr
end
time = Time.now
# get the raw html of github.com/trending
trending_page_html = Nokogiri::HTML(open('https://github.com/trending'))
# get an array of html snippets, each representing one repo
repo_html_list = trending_page_html.css('.repo-list-name a')
repo_name_list = repo_html_list.map do |f|
  f.content.delete("\n").delete(' ')
end
# This is to prevent rate limiting, fix before GitHubbing
repo_name_list = [repo_name_list[0], repo_name_list[1]]
repo_object_list = repo_name_list.map do |f|
  Repo.new(f)
end

# In the future, this should not delete old data.sqlite
File.delete('./data.sqlite')
db = SQLite3::Database.new 'data.sqlite'
create_execute = 'create table data('
repo_object_list[0].api_hash.each do |p|
  create_execute += p[0]
  create_execute += ', ' if repo_object_list[0].api_arr.index(p[1]) < repo_object_list[0].api_arr.length - 1
end
create_execute += ');'
pp create_execute
db.execute create_execute
repo_object_list.each do |f|
  p f.api_arr.length # for debug
  db.execute 'insert into data values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? );', f.api_arr
end

db.execute('select * from data') do |r|
  # pp r
end
