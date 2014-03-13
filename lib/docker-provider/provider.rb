require_relative 'api_driver'
require_relative 'driver'
require_relative 'action'

module VagrantPlugins
  module DockerProvider
    class Provider < Vagrant.plugin("2", :provider)
      attr_reader :driver

      def initialize(machine)
        @logger  = Log4r::Logger.new("vagrant::provider::docker")
        @machine = machine
        @driver  = case machine.provider_config.driver
        when :cli then Driver.new
        when :api then ApiDriver.new(machine.provider_config.socket)
        # should never get here...
        else raise "Unknown driver type of #{machine.provider_config.driver}"
        end
      end

      # @see Vagrant::Plugin::V2::Provider#action
      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      # Returns the SSH info for accessing the Container.
      def ssh_info
        # If the Container is not created then we cannot possibly SSH into it, so
        # we return nil.
        return nil if state == :not_created

        network = @driver.inspect_container(@machine.id)['NetworkSettings']
        ssh_binding = network['Ports']['22/tcp'].first
        ip = ssh_binding['HostIp']
        port = ssh_binding['HostPort']

        # If we were not able to identify the container's IP, we return nil
        # here and we let Vagrant core deal with it ;)
        return nil unless ip && port

        {
          :host => ip,
          :port => port
        }
      end

      def state
        state_id = nil
        state_id = :not_created if !@machine.id || !@driver.created?(@machine.id)
        state_id = @driver.state(@machine.id) if @machine.id && !state_id
        state_id = :unknown if !state_id

        short = state_id.to_s.gsub("_", " ")
        long  = I18n.t("vagrant.commands.status.#{state_id}")

        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id ? @machine.id : "new container"
        "Docker (#{id})"
      end
    end
  end
end
