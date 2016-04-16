#!/usr/bin/env ruby

require 'nokogiri'
require 'json'
require 'open-uri'

class Repo
  def initialize(full_name)
    @name = %r{/(\w+)}.match(full_name)[1]
    @api_url = 'https://api.github.com/repos/' + full_name
    # to use API authentication, modify the request here
    rate_limited = JSON.parse(open('https://api.github.com/rate_limit').read)['resources']['core']['remaining'] == 0
    info unless rate_limited
  end

  def info
    # to use API authentication, modify the request here
    @api_hash = JSON.parse(open(@api_url).read)
    @api_arr = []
    @api_hash.each do |p|
      @api_arr.push(p[1])
    end
  end

  attr_reader :name, :api_hash, :api_arr
end

trending_page_html = Nokogiri::HTML(open('https://github.com/trending'))
repo_html_list = trending_page_html.css('.repo-list-name a')
repo_name_list = repo_html_list.map do |f|
  f.content.delete("\n").delete(' ')
end
repo_object_list = repo_name_list.map do |f|
  Repo.new(f)
end

repo_object_list.each do |f|
  puts f.name
end
