# GitHub Trending Scraper

###### It scrapes the GitHub trending page!

This script uses [Nokogiri](http://www.nokogiri.org) to scrape https://github.com/trending, then gets info on each repo using the GitHub API. It is a [morph.io](https://morph.io)-compatible scraper, meaning you can use it as an API as well as locally.

## Setup

    $ git clone https://github.com/nloveladyallen/github_trending
    $ cd github_trending
    $ gem install


## Usage

### Locally

    $ export MORPH_UNAME='yourgithubusername'
    $ export MORPH_PWD='yourgithubpassword'
    $ ./scraper.rb
    
Creates data.sqlite, containing one table, data, with one column for every part of the GitHub API and one row for every trending item (there are 25 at any given time).

### API

Data from this scraper is available from [morph.io](https://morph.io). You must have a morph.io API key. Signing up is free, and only requires a GitHub account. A morph.io request looks like this:

    GET https://api.morph.io/nloveladyallen/github_trending/data.[format]?key=[api_key]&query=[sql]
    
See the [morph.io API documentation](https://morph.io/documentation/api) for more details.