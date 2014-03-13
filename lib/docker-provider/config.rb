require 'docker'

module VagrantPlugins
  module DockerProvider
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :image, :cmd, :ports, :volumes, :privileged, :driver, :socket

      def initialize
        @image      = nil
        @cmd        = UNSET_VALUE
        @ports      = []
        @privileged = UNSET_VALUE
        @volumes    = []
        @driver     = :cli
        @socket     = UNSET_VALUE
      end

      def finalize!
        @cmd        = [] if @cmd == UNSET_VALUE
        @privileged = false if @privileged == UNSET_VALUE
        @socket     = ::Docker.url
      end

      def validate(machine)
        errors = _detected_errors

        # TODO: Detect if base image has a CMD / ENTRYPOINT set before erroring out
        errors << I18n.t("docker_provider.errors.config.cmd_not_set")   if @cmd == UNSET_VALUE

        unless %i[cli api].include?(@driver)
          errors << I18n.t("docker_provider.errors.config.invalid_driver")
        end

        if @driver == :api && @socket.nil? || @socket == UNSET_VALUE
          errors << I18n.t("docker_provider.errors.config.socket_not_set")
        end

        { "docker-provider" => errors }
      end

      def create_params(env)
        machine = env[:machine]

        container_name = "#{env[:root_path].basename.to_s}_#{machine.name}"
        container_name.gsub!(/[^-a-z0-9_]/i, "")
        container_name << "_#{Time.now.to_i}"

        {
          image:      image,
          cmd:        cmd,
          ports:      (env[:forwarded_ports] || []).map do |fp|
                        # TODO: Support for the protocol argument
                        "#{fp[:host]}:#{fp[:guest]}"
                      end.compact,
          name:       container_name,
          hostname:   machine.config.vm.hostname,
          volumes:    volumes,
          privileged: privileged
        }
      end

      private

      def using_nfs?(machine)
        machine.config.vm.synced_folders.any? { |_, opts| opts[:type] == :nfs }
      end
    end
  end
end
