# Redis-session-store
begin
  require_library_or_gem 'redis'

  module ActionController
    module Session
      class RedisSessionStore < AbstractStore
        def initialize(app, options = {})
          # Support old :expires option
          options[:expire_after] ||= options[:expires]
          super
          @options = {:host => '127.0.0.1',:port => '6379'}.merge(options)
          @server = Redis.new @options
          super
        end
        private
        def get_session(env, sid)
          puts sid
          begin
            session = @server.get(sid)
          rescue Errno::ECONNREFUSED
            session = {}
          end
          [sid, unmarshal(session)]
        end

        def set_session(env, sid, session_data)
          @server.set(sid, marshal(session_data) )
          return true
        rescue Errno::ECONNREFUSED
          return false
        end
        def marshal(data)
          ActiveSupport::Base64.encode64(YAML.dump(data)) if data
        end

        def unmarshal(data)
          if data
            YAML.load(ActiveSupport::Base64.decode64(data)) 
          else
            {}
          end
        end
        
      end
    end
  end
rescue LoadError
  # MemCache wasn't available so neither can the store be
end
