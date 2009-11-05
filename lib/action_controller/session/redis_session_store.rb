# Redis-session-store
begin
  require_library_or_gem 'redis'
  module ActionController
    module Session
      class RedisSessionStore < AbstractStore
        def initialize(app, options = {})
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
          ActiveSupport::Base64.encode64(Marshal.dump(data)) if data
        end

        def unmarshal(data)
          if data
            Marshal.load(ActiveSupport::Base64.decode64(data)) 
          else
            {}
          end
        end        
      end
    end
  end
rescue LoadError
  # Redis wasn't available so neither can the store be
end
