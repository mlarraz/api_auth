require 'faraday'

# Middleware to automatically sign Faraday requests.
#
#  Faraday.new do |builder|
#    builder.request :api_auth, 'access_id', 'secret_key'
#  end
#
module ApiAuth
  class FaradayMiddleware < Faraday::Middleware
    def initialize(app, access_id, secret_key, options = {})
      super(app)

      @access_id  = access_id
      @secret_key = secret_key
      @options    = options
    end

    def call(env)
      ApiAuth.sign!(env, @access_id, @secret_key, @options)
      @app.call(env)
    end
  end
end

Faraday::Request.register_middleware api_auth: ApiAuth::FaradayMiddleware
