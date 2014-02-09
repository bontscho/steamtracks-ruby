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

# require 'steam_tracks' # include gem if you are not inside rails

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

Returns a list of users and their updated fields since a given timestamp (useful for update workers).
Optional 2nd parameter fields to only yield given fields.

```ruby

result = SteamTracks.userChanges(1390337790452)
result_only_updated_playername = SteamTracks.userChanges(1390337790452, ['playerName'])

# result => {
#      "next_timestamp": 1390337790452,
#      "num_results": 50,
#      "users": [
#        "12345678": {
#          "playerName": "Player1 new name",
#          "personaState": "3",
#          "dota2": {
#            "wins": "1337"
#          }
#        },
#        "23456789": {
#          "personaState": "0",
#          "dota2": {
#            "wins": "500",
#            "friendly": "15",
#            "soloCompetitiveRank": "3531"
#          }
#        }
#      ]
#}

from_timestamp = result["next_timestamp"]
changed_users = result["users"]

# ... perform change logic

# next time request will be
result_next = SteamTracks.userChanges(from_timestamp)
# ...
```

#### Notifications

##### /notify

Sends a notification to a list of users or all users of your app.

```ruby
# message to single user
SteamTracks.notify({
    message: "Message goes here",
    to: 123123123
})

# message to list of users
SteamTracks.notify({
    message: "Message goes here",
    to: [123123123, 312312323, 412541242]
})

# message to all users of your app
SteamTracks.notify({
    message: "Message goes here",
    broadcast: true
})

# message to all users of your app except offline
SteamTracks.notify({
    message: "Message goes here",
    broadcast: true,
    exclude_offline: true
})
```

## Examples & Recommendations

If you want to stay updated on the information of your users, you will only need the following functions if you do it in the following elaborated way:

    /signup/token
    /signup/status
    /signup/ack

    /users/changes
    /users/flushleavers

Optional for extra information:

    /users/states
    /users/games

    extra services:
    /notify

Full SteamTracks integration into a Rails 4 project with existing User model

### Example model for SteamTracks

Add `is_steamtracks` boolean to user model to have a local flag on which user has authorized Steamtracks:

    $ rails g migration add_is_steamtracks_to_users is_steamtracks:boolean

```ruby
# db/migrate/xxx_add_is_steamtracks_to_users.rb

class AddIsSteamtracksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_steamtracks, :boolean, null: false, default: false
  end
end
```

Now create a model with all fields you want to stay updated on (according to your app permissions).

    $ rails g model UserSteamTracks user_id:integer personastate:integer ... dota2_teamlogo

Full migration example:

```ruby
# db/migrate/xxx_create_user_steam_tracks.rb

class CreateUserSteamTracks < ActiveRecord::Migration
  def change
    create_table :user_steam_tracks do |t|
      t.integer :user_id
      t.integer :personastate
      t.string :playername
      t.string :gameplayedappid
      t.string :gamename
      t.integer :dota2_xp
      t.integer :dota2_level
      t.integer :dota2_recruitmentlevel
      t.integer :dota2_showcasehero
      t.integer :dota2_wins
      t.integer :dota2_competitiverank
      t.integer :dota2_calibrationgamesremaining
      t.integer :dota2_solocompetitiverank
      t.string :dota2_solocalibrationgamesremaining
      t.integer :dota2_teaching
      t.integer :dota2_leadership
      t.integer :dota2_friendly
      t.integer :dota2_forgiving
      t.string :dota2_teamname
      t.string :dota2_teamtag
      t.string :dota2_teamlogo

      t.timestamps
    end
    add_column :user_steam_tracks, :gameid, :numeric
    add_column :user_steam_tracks, :dota2_teamid, :numeric
    add_index :user_steam_tracks, :user_id, unique: true
  end
end
```

The model:

```ruby
# app/models/user_steam_tracks.rb

class UserSteamTracks < ActiveRecord::Base
  # user relation
  belongs_to :user

  # if you have stored personaname in your user model aswell, this callback
  # will keep both in sync
  before_save :update_personaname

  def update_personaname
    if self.playername_changed?
      self.user.personaname = self.playername
      self.user.save
    end
  end

end
```



# TODO: finish these docs up

## Contributing

1. Fork it ( https://github.com/bontscho/steamtracks-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
