require 'active_support/core_ext/module/attribute_accessors'
require_relative "steam_tracks/version"
require_relative "steam_tracks/base"

module SteamTracks
  mattr_accessor :api_key, :api_secret, :api_version, :api_base, :steamtracks_base
  @@api_key = nil
  @@api_secret = nil
  @@api_version = 1
  @@api_base = "https://steamtracks.com/api"
  @@steamtracks_base = "https://steamtracks.com"

  def self.setup
    yield self if block_given?
  end

  # redirect all request to corresponding api version module
  def self.method_missing(m, *args, &block)
    receiver = Kernel.const_get("SteamTracks::Api::V" + self.api_version.to_s)

    if receiver.respond_to?(m.to_sym)
      receiver.send(m, *args)
    else
      super
    end
  end
end
