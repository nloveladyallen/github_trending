#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'open-uri'
require 'sqlite3'

# See api.github.com for documentation on the GitHub API. This script
# blindly takes all parts of the API and sticks them in the database,
# except for handling owner type (organization or user).

# Given a repo name, gets info using the GitHub API
class Repo
  # Full name is in the form "nloveladyallen/github_trending"
  def initialize(full_name)
    # GitHub login, uses MORPH_ prefix to make morph.io happy
    @login = [ENV['MORPH_UNAME'], ENV['MORPH_PWD']]
    abort 'Set $MORPH_UNAME and $MORPH_PWD' if @login == [nil, nil]
    @api_url = 'https://api.github.com/repos/' + full_name
    # Check if rate limited
    rate_limit_url = 'https://api.github.com/rate_limit'
    rate_limit_page = open rate_limit_url, http_basic_authentication: @login
    rate_limit_json = JSON.parse rate_limit_page.read
    rate_limited = rate_limit_json['resources']['core']['remaining'].zero?
    info unless rate_limited
  end

  # Escape single and double quotes with &quot; and &apos;
  def escape(s)
    s.to_s.gsub('"', '&quot;').gsub("'", '&apos;')
  end

  # Retrieve, sort and save parsed JSON into appropriate variables
  def info
    # Get raw JSON of GitHub API
    api_page = open @api_url, http_basic_authentication: @login
    # Parse the JSON into a hash
    @api_hash = JSON.parse api_page.read
    # Consistency between repos owned by organizations and individuals
    @api_hash['organization'] = @api_hash['owner']
    # Alphebatize the API hash
    @api_sort = @api_hash.sort
    # Convert to array because SQLite
    @api_arr = []
    @api_sort.each do |_, v|
      if v.is_a? Hash
        v.each { |_, w| @api_arr.push escape w }
      else
        @api_arr.push escape v
      end
    end
  end
  # Repos are read-only
  attr_reader :api_sort, :api_arr
end

# Get the raw HTML of https://github.com/trending
trending_page_html = Nokogiri::HTML open 'https://github.com/trending'
# Get an array of HTML snippets, each representing one repo
repo_html_list = trending_page_html.css 'h3 a'
# Remove extraneous HTML to get an array of full names ("owner/repo")
repo_name_list = repo_html_list.map { |f| f.content.delete("\n").delete(' ') }
# Turn these names into Repos
repo_object_list = repo_name_list.map { |f| Repo.new f }

# Delete old database (possible improvement: allow storage of historical data)
File.delete './data.sqlite'
# Create new database data.sqlite
db = SQLite3::Database.new 'data.sqlite'
# Create SQL command to create the data table
create_execute = 'CREATE TABLE data('
# Add the indexes of the sorted hash of the GitHub API as table columns
repo_object_list.first.api_sort.each_with_index do |pr, i|
  # Deal with the hashes in the API data, e.g.
  # {"owner"=>{"login"=>"nloveladyallen"}} to {"owner_login"=>"nloveladyallen"}
  if pr[1].is_a? Hash
    pr[1].each_with_index do |qr, j|
      create_execute += pr[0] + '_' + qr[0]
      create_execute += ', ' if j < pr[1].length - 1
    end
  else
    create_execute += pr[0]
  end
  # Is this the last item in the hash?
  create_execute += ', ' if i < repo_object_list.first.api_sort.length - 1
end
create_execute += ');'
db.execute create_execute

repo_object_list.each do |r|
  # Create SQL command to insert data into the data table
  insert_execute = 'INSERT INTO data VALUES ('
  # Add the values of the array of the GitHub API as row values
  r.api_arr.each_with_index do |v, i|
    insert_execute += '"' + v + '"'
    insert_execute += ', ' if i < r.api_arr.length - 1
  end
  insert_execute += ');'
  db.execute insert_execute
end
