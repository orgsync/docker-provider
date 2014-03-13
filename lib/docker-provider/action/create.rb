module VagrantPlugins
  module DockerProvider
    module Action
      class Create
        def initialize(app, env)
          @app = app
          @@mutex ||= Mutex.new
        end

        def call(env)
          machine         = env[:machine]
          provider_config = machine.provider_config
          driver          = machine.provider.driver

          guard_cmd_configured!(machine)

          cid = ''
          @@mutex.synchronize do
            cid = driver.create(provider_config.create_params(env))
          end

          machine.id = cid
          @app.call(env)
        end

        def guard_cmd_configured!(machine)
          if ! machine.provider_config.image
            raise Errors::ImageNotConfiguredError, name: machine.name
          end
        end
      end
    end
  end
end
