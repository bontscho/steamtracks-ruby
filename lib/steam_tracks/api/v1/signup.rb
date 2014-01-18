module SteamTracks
  module Api
    class V1
      def self.getSignupToken
        result = self.request :get, "signup/token"
        return result["token"] if result["token"]
        nil
      end

      def self.getSignupURL(token = nil)
        if token.nil?
          token = self.getSignupToken
        end
        "#{SteamTracks.steamtracks_base}/appauth/#{token}"
      end

      def self.getSignupStatus(token)
        result = self.request :get, "signup/status", { token: token }
        return result
      end

      def self.ackSignup(token, user = nil)
        data = { token: token }
        data[:user] = user unless user.nil?
        self.request :post, "signup/ack", data
      end
    end
  end
end