require 'uri'
require 'base64'
require 'openssl'
require 'net/http'
require 'net/https'
require 'awesome_print'
require 'json'

module SteamTracks
  module Api
    class V1
      def self.request method, resource, params = {}
        url = "#{SteamTracks.api_base}/v#{SteamTracks.api_version}/#{resource}"

        # add time param for security
        params[:t] = Time.now.to_i

        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host, uri.port)
        #https.use_ssl = true
        #https.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
        request = nil
        payload = params.to_json
        signature = Base64.encode64(OpenSSL::HMAC.digest('sha1', SteamTracks.api_secret, payload))

        if method == :get
          request = Net::HTTP::Get.new(uri, { 'Content-Type' => 'application/json'})
        elsif method == :post
          request = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json'})
        else
          raise "invalid request method"
        end

        request.body = payload

        request["SteamTracks-Key"] = SteamTracks.api_key
        request["SteamTracks-Signature"] = URI.encode(signature)
        request["ACCEPT"] = "application/json"

        response = https.request(request)

        json = JSON(response.body)
        #debug
        #puts json
        #return
        #debug
        if response.code.to_i != 200
          raise json["error"]
        end
        return json["result"] if json.has_key?("result")
        json
      end
    end
  end
end