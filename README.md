# SteamTracks

This Gem implements the [SteamTracks](https://steamtracks.com) API to use in a very comfortable way.

## Installation

Add this line to your application's Gemfile:

    gem 'steam_tracks', '0.1.5'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install steam_tracks -v '0.1.5'

## Usage

### Initializing

Initialize the API data. For Rails put this into `config/initializers/steam_tracks.rb`

    SteamTracks.setup do |config|
      config.api_key = "API_KEY"
      config.api_secret = "API_SECRET"
    end

## Contributing

1. Fork it ( https://github.com/bontscho/steamtracks-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
