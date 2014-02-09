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

##### /users/info

Get info for a certain user (by SteamID32)

```ruby

info = SteamTracks.userInfo(12345678)
# info => {
#   "userinfo": {
#       "steamid32": 12345678,                        // user's SteamID32(Int)
#       "joined_app_at": "2014-01-01T00:30:01.337Z",  // time when users joined the app
#       "personaState": "1",
#       "playerName": "Player1",
#       [...],
#       "dota2": {
#         "level": "100",
#         "recruitmentLevel": "42",
#         [...]
#       }
#     }
#}

userinfo = info["userinfo"]
```

##### /users/states

Information about your users' online status. Useful for statistics on your website (to show activity and such).

```ruby

result = SteamTracks.userStates
# result => {
#   "states": {
#       "1": 123,
#       "0": 65,
#       "3": 30,
#       "2": 3,
#       "4": 14
#   }
#}

states = result["states"]

# count offline and online users
online = 0
offline = 0
states.each do |k,v|
    k == "0" ? offline += v : online += v
end

# online => 170
# offline => 65
```

##### /users/games

Information about your users' currently played games. Useful for statistics on your website (like the states)

```ruby

result = SteamTracks.userGames

# result => {
#   "games": {
#        "570": {          // Steam Game AppID(String)
#          "n":  "Dota 2"  // Name of Game (useful for added Non-Steam Games)
#          "o": 1337,      // 1337 users are online in Dota 2
#          "p": 345        // 345 of those 1337 users are playing an active match of Dota 2 right now
#        },
#        "730": {
#          "n": "Counter-Strike: Global Offensive"
#          "o": 567,
#          "p": 123
#        },
#        [...]
#      }
#    }
#}

games = result["games"]
# ... further enhance your information here ...
```

##### /users/leavers

Returns a list of all users that have left your app.

```ruby

result = SteamTracks.userLeavers
# result => {
#    "num_results": 42,   // total number of users that left
#    "leavers": [
#        12345678,           // SteamID32 of user
#        12345679,
#        [...]
#    ]
#}

leavers = result["leavers"]
```

##### /users/flushleavers

Same as `/users/leavers` with the difference that it deletes the list on the server (useful for update workers)

```ruby

result = SteamTracks.userFlushLeavers
# ....
```

##### /users/changes

#### Notifications

##### /notify

# TODO: finish these docs up

## Examples & Recommendations

## Contributing

1. Fork it ( https://github.com/bontscho/steamtracks-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
