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

#### User Model flag

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

#### The Migration

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

#### The Model

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

### Example Signup process and Route

#### Route

Add routes to your `config/routes.rb`:

```ruby
get "/steamtracks/signup" => "steam_tracks#signup", as: "steamtracks_signup"
get "/steamtracks/callback" => "steam_tracks#callback", as: "steamtracks_callback"
```

#### Signup Controller

```ruby
# app/controllers/steam_tracks_controller.rb

# inherits from UserApplicationController that only allows logged in users to access that controller
class SteamTracksController < UserApplicationController

  # signup:
  # if user is not in steamtracks, send him off to the signup url
  # if not, redirect to root_path
  def signup
    if current_user.is_steamtracks
      redirect_to root_path, notice: "You already authorized SteamTracks"
    else
      url = SteamTracks.getSignupURL
      redirect_to url
    end

  rescue
    redirect_to root_path, alert: "An Error occured, please try again later"
  end

  def callback
    # allow only token parameter and extract token
    cb_info = set_callback_info
    token = cb_info[:token]

    # retrieve information on that token
    info = SteamTracks.getSignupStatus(token)

    # if user accepted, check if the steamid matches your steamid in case the user sign up on steamtracks with a different account
    # you can optionally specify an allowed steamid when getting the signup token
    if info["status"] == "accepted"
      if info["user"] != current_user.steamid32
        redirect_to root_path, alert: "You have to authorize SteamTracks with the same account as here"
        return
      end

      # user is the right one, acknowlege the signup and get userinfo
      result = SteamTracks.ackSignup(token, info["user"])
      userinfo = result["userinfo"]

      # reduce the nested json userinfo hash to match your steamtracks database model
      # (this can be put into a helper because it will be used later again)
      newinfo = {}
      userinfo.each do |k,v|
        # look out for joined_app_at, steamid32 and dota2
        next if k == "joined_app_at" || k == "steamid32"

        if k == "dota2"
          v.each do |dk,dv|
            newinfo["dota2_#{dk.downcase}".to_sym] = dv
          end
          next
        end

        newinfo[k.downcase.to_sym] = v
      end

      # then create the steamtracks model accordingly and update the is_steamtracks flag in your model
      current_user.steam_tracks = UserSteamTracks.new(newinfo)
      current_user.steam_tracks.save
      current_user.is_steamtracks = true
      current_user.save

      redirect_to root_path, notice: "Successfully authorized SteamTracks"
    else
      # ack decline
      SteamTracks.ackSignup(token)
      redirect_to root_path, alert: "SteamTracks authorization declined, feel free to authorize at a later time"
    end
  rescue
    redirect_to root_path, alert: "An Error occured, please try again later"
  end

  private
  def set_callback_info
    params.permit(:token)
  end
end
```

### Example Sidekiq/Cron workers to keep data in sync

Now you can stay in sync with your data by just running workers regularly that process:

1. left users
2. changed fields

By doing so you always stay updated on the data and you have no need to crawl the user list or a single user's information.


#### Leaver Worker

This Sidekiq worker runs every 10 minutes via `whenever` gem.

Schedule code:

```ruby

every 10.minutes do
  runner 'LeaverWorker.perform_async'
end
```

Worker Code:
```ruby

class LeaverWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    leavers = SteamTracks.userFlushLeavers

    # gets list of leavers and removes steamtracks model and sets is_steamtracks flag accordingly
    if leavers["num_results"] > 0
      leavers["leavers"].each do |u32|
        user = User.find_by_steamid32(u32)
        if user.is_steamtracks
          user.is_steamtracks = false
          user.save
          user.steam_tracks.destroy
        end
      end
    end
  end
end
```

#### Changes Worker

This worker runs like the leaver worker every 10 minutes.

Worker Code:

```ruby

class ChangesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    # get latest timestamp which is stored in a textfile
    # this can also be put into a database, this is just an improvised example
    delta_file = File.join(Rails.root, "config", "delta_from_timestamp")
    next_timestamp = File.read(delta_file).to_i

    begin
      data = SteamTracks.userChanges(next_timestamp)
      data["users"].each do |steamid32,hash|
        user = User.find_by_steamid32(steamid32.to_i)
        next if user.nil?

        # this is the same method of reducing the nested json hash like in the signup controller
        # putting this into a helper is handy
        newinfo = {}
        hash.each do |k,v|
          next if k == "joined_app_at" || k == "steamid32"

          if k == "dota2"
            v.each do |dk,dv|
              newinfo["dota2_#{dk.downcase}".to_sym] = dv
            end
            next
          end

          newinfo[k.downcase.to_sym] = v
        end

        user.steam_tracks.assign_attributes(newinfo)
        if user.steam_tracks.changed?
          user.steam_tracks.save
        end
      end

      # store next timestamp and loop as long as the query returns >= 100 results
      next_timestamp = data["next_timestamp"]
    end until data["num_results"] < 100

    # worker is done, save the latest next_timestamp for the next worker in 10 minutes
    File.open(delta_file, 'w') {|f| f.write(next_timestamp) }
  end
end
```

Those 2 workers will keep your data completely in sync, it's really that simple :)

## Contributing

1. Fork it ( https://github.com/bontscho/steamtracks-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
