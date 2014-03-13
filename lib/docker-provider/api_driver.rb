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
        if created?(cid)
          if running?(cid)
            :running
          else
            :stopped
          end
        else
          :not_created
        end
      end

      def created?(cid)
        all_containers.include?(cid)
      end

      def running?(cid)
        inspect_container(cid)['State']['Running']
      end

      def privileged?(cid)
        inspect_container(cid)['HostConfig']['Privileged']
      end

      def start(cid)
        container(cid).start! if created?(cid)
      end

      def stop(cid)
        container(cid).stop! if running?(cid)
      end

      def rm(cid)
        container(cid).remove
      end

      def inspect_container(cid)
        container(cid).json
      end

      def all_containers
        ::Docker::Container.all({:all => true}, @api).map(&:id)
      end

      def docker_bridge_ip
        raise "TODO: docker_bridge_ip"
      end

      private

      def container(cid)
        ::Docker::Container.get(cid, nil, @api)
      end

    end
  end
end
