module SteamTracks
  module Api
    class V1
      def self.generateSignupToken
        result = self.request :get, :token
        return result["token"] if result["token"]
        nil
      end

      def self.getSignupURL
        token = self.generateSignupToken
        "#{SteamTracks.steamtracks_base}/appauth/#{token}"
      end
    end
  end
end