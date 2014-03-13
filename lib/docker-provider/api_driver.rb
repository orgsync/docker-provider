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
        config = create_container_config(params)
        container = ::Docker::Container.create(config, @api)
        container.id
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

      def start(cid, params = {})
        config = create_container_config(params)
        container(cid).start!(config) if created?(cid)
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
        # TODO: not sure what to do here...  I see its only used for NFS.
        raise "TODO: docker_bridge_ip"
      end

      private

      def container(cid)
        ::Docker::Container.get(cid, nil, @api)
      end

      # TODO: mostly yanked from `kitchen-docker`
      # https://github.com/portertech/kitchen-docker/blob/1c46c6054267214b0c241675321bef7436abd090/lib/kitchen/driver/docker.rb#L127-L151
      def create_container_config(params)
        data = {
          :Cmd => Array(params.fetch(:cmd)),
          :Image => params.fetch(:image),
          :AttachStdout => true,
          :AttachStderr => true,
          :Privileged => params[:privileged],
          :PublishAllPorts => false
        }
        data[:Hostname] = params.fetch(:hostname)
        forward = ['22'] + Array(params[:ports]).map { |mapping| mapping.to_s }
        forward.compact!
        data[:PortSpecs] = forward
        data[:PortBindings] = forward.inject({}) do |bindings, mapping|
          guest_port, host_port = mapping.split(':').reverse
          bindings["#{guest_port}/tcp"] = [{
            :HostIp => '',
            :HostPort => host_port || ''
          }]
          bindings
        end
        data[:Volumes] = Hash[Array(params[:volumes]).map { |volume| [volume, {}] }]
        data
      end

    end
  end
end
