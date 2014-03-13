require 'docker'
require 'log4r'
require 'json'

module VagrantPlugins
  module DockerProvider
    class ApiDriver

      def initialize(socket, read_timeout = 500)
        @api= ::Docker::Connection.new(socket, :read_timeout => read_timeout)
        @logger = Log4r::Logger.new("vagrant::docker::api_driver")
      end

      def create(params)
        raise "TODO: creating with params #{params.inspect}!"
      end

      def state(cid)
        raise "TODO: State for #{cid}"
      end

      def created?(cid)
        raise "TODO: Created? for #{cid}"
      end

      def running?(cid)
        raise "TODO: running? for #{cid}"
      end

      def privileged?(cid)
        raise "TODO: privaliged? for #{cid}"
      end

      def start(cid)
        raise "TODO: start for #{cid}"
      end

      def stop(cid)
        raise "TODO: stop for #{cid}"
      end

      def rm(cid)
        raise "TODO: rm for #{cid}"
      end

      def inspect_container(cid)
        raise "TODO: inspect_container for #{cid}"
      end

      def all_containers
        raise "TODO: all_containers"
      end

      def docker_bridge_ip
        raise "TODO: docker_bridge_ip"
      end

    end
  end
end
