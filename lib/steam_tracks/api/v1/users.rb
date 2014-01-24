module SteamTracks
  module Api
    class V1
      def self.userStates
        self.request :get, "users/states"
      end

      def self.userGames
        self.request :get, "users/games"
      end

      def self.userInfo(user32)
        self.request :get, "users/info", { user: user32 }
      end

      def self.userList(page = nil)
        arguments = (page.nil? ? {} : {page: page})
        self.request :get, "users", arguments
      end

      def self.userCount
        self.request :get, "users/count"
      end

      def self.userLeavers
        self.request :get, "users/leavers"
      end

      def self.userFlushLeavers
        self.request :post, "users/flushleavers"
      end

      def self.userDelta(from_timestamp = nil, fields = [])
        arguments = {}
        arguments[:from_timestamp] = (from_timestamp.nil? ? 0 : from_timestamp.to_i)
        arguments[:fields] = fields unless fields.count == 0
        self.request :get, "users/delta", arguments
      end
    end
  end
end