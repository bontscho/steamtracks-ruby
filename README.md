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

```ruby
SteamTracks.setup do |config|
  config.api_key = "API_KEY"
  config.api_secret = "API_SECRET"
end
```

### API Functions

#### Signup Process

##### /signup/token

Get a token for the signup process

```ruby
# just get a token
token = SteamTracks.getSignupToken
# token => "xxxxxxxxxxxxxxxxxxxx"

# force a certain steamid
token = SteamTracks.getSignupToken({steamid: 123456789})
# token => "xxxxxxxxxxxxxxxxxxxx"

# add the steamid to the callback url
token = SteamTracks.getSignupToken({return_steamid32: true})
# token => "xxxxxxxxxxxxxxxxxxxx"
```


Get the Signup URL

```ruby
# get signup url via token
token = SteamTracks.getSignupToken(arguments)
url = SteamTracks.getSignupURL(token)

# or use the shortcut to directly get the signup url for given (optional) arguments
url = SteamTracks.getSignupURL(nil, arguments)
# default url with default token
url = SteamTracks.getSignupURL

# quick way of starting the appauth
redirect_to SteamTracks.getSignupURL
```


##### /signup/status

Get the Status of for a given token (e.g. at the callback URL)

```ruby
token = "xxxxxxxxxxxxxxxxxxxx" # or in rails params[:token]

info = SteamTracks.getSignupStatus(token)
# info => {
#   "status": "accepted",
#   "user": 12345678
#}
```

##### /signup/ack

Acknowledge the Signup Process. If the user has accepted, add the SteamID32, if not, just acknowledge (optional) to instantly remove the Signup Token from the server.

```ruby
token = "xxxxxxxxxxxxxxxxxxxx"
info = {
    "status": "accepted",
    "user": 12345678
}

result = SteamTracks.ackSignup(token, info["user"])

# result => {
#    "status": "OK",
#    "userinfo": {
#      "personaState": "1",
#      "playerName": "Player1",
#      [...],
#      "dota2": {
#        "level": "100",
#        "recruitmentLevel": "42",
#        [...]
#      }
#    }
#  }

userinfo = result["userinfo"]

# userinfo holds all data for the given user, continue to process in your logic
```

#### User Functions

##### /users

Get a list of all users (100 per page).

```ruby

users_page1 = SteamTracks.userList
# users_page1 => {
#   "num_pages": 10,
#   "num_results": 994,
#   "users": [...]
# }

# array of users is here:
users = users_page1["users"]

# get users on page 2
users_page2 = SteamTracks.userList(2)

```

##### /users/count

Get the number of users in your app

```ruby

count = SteamTracks.userCount
# count => {"users" : 1337}

```


## Contributing

1. Fork it ( https://github.com/bontscho/steamtracks-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
