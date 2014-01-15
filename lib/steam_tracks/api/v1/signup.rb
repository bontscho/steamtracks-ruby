module SteamTracks
  module Api
    class V1
      def self.getSignupToken
        result = self.request :get, :signuptoken
        return result["token"] if result["token"]
        nil
      end

      def self.getSignupURL(token = nil)
        if token.nil?
          token = self.getSignupToken
        end
        "#{SteamTracks.steamtracks_base}/appauth/#{token}"
      end
    end
  end
end