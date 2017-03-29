module Minke
  module Config
    ##
    # URL represents a url object which is used for health_check and consul_loader locations
    class URL
      ##
      # address of the server i.e 127.0.0.1 or the docker name consul
      attr_accessor :address

      ##
      # port which the server is running on
      # default 80
      attr_accessor :port

      ##
      # protocol for the server
      # - http [default]
      # - https
      attr_accessor :protocol

      ##
      # path for the server
      # default /
      attr_accessor :path

      ##
      # type of the URL
      # - public
      # - private used for linked containers
      attr_accessor :type
    end
  end
end
