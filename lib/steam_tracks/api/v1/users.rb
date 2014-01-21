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
    end
  end
end