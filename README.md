# Github Trending Scraper

> It scrapes the Github trending page!

This script uses [Nokogiri](http://www.nokogiri.org/) to search https://github.com/trending, then gets info on each repo using the Github API. It can be used as a CLI, as a dependency, or as a [morph.io](https://morph.io)-compatible scraper.

## Setup

    $ git clone https://github.com/nloveladyallen/github_trending
    $ cd github_trending
    $ gem install

### Authentication

You might want to add authentication for the API. While this is completely optional, you may run into rate-limiting otherwise.

To authenticate, create a file, login.txt, containing your username and password, separated by a newline. On run, the script will ask if you want to generate an OAuth token. If you choose to, login.txt will be deleted and token.txt will be created.

## Usage

### CLI

    $ ./scraper.rb
    
If it does not already exist, it creates an sqlite3 database, data.sqlite, with the data. If it does exist, it will move it to data.sqlite.bak, then create data.sqlite.

For more options, see `./scraper.rb -h`.

### Dependency

**TODO**

### API

Data from this scraper is available from [morph.io](https://morph.io). You must have a morph.io API key. Signing up is free, and only requires a Github account. A morph.io request looks like this:

    GET https://api.morph.io/nloveladyallen/github_trending/data.[format]?key=[api_key]&query=[sql]