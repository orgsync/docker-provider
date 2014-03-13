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

        if @socket == UNSET_VALUE && docker_host = ENV['DOCKER_HOST']
          @socket = docker_host
        end
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

      private

      def using_nfs?(machine)
        machine.config.vm.synced_folders.any? { |_, opts| opts[:type] == :nfs }
      end
    end
  end
end
