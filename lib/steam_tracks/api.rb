module SteamTracks
  module Api
    mattr_reader :versions
    # all available api versions
    @@versions = [ 1 ]
  end
end