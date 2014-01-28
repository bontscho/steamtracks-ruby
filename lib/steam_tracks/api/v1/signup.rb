module SteamTracks
  module Api
    class V1
      def self.getSignupToken(arguments = {})
        result = self.request :get, "signup/token", arguments
        return result["token"] if result["token"]
        nil
      end

      def self.getSignupURL(token = nil, arguments = {})
        if token.nil?
          token = self.getSignupToken(arguments)
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