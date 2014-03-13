module VagrantPlugins
  module DockerProvider
    module Action
      class Start
        def initialize(app, env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          driver  = machine.provider.driver
          driver.start(machine.id, machine.provider_config.create_params(env))
          @app.call(env)
        end
      end
    end
  end
end
