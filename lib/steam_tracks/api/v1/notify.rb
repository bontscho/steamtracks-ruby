module SteamTracks
  module Api
    class V1
      def self.notify(options = {})
        self.request :post, "notify", options
      end
    end
  end
end