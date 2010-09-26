# Convenience to facilitate moving files to and from a server file system
# to the cloud.  The primary use is to move uploaded temp files so that any
# server (particularly delayed_job servers) can get at and share the data.
module Trackster
  class Cloudfiles
    
    def self.copy_uploaded(filename)
      # upload_container.load_from_filename(filename)
    end

  private
    def self.upload_container
      # default credentials for connection, default container
      # connect via snet in production
    end
end