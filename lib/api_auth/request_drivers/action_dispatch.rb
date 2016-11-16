module ApiAuth
  module RequestDrivers # :nodoc:
    class ActionDispatchRequest < ActionControllerRequest # :nodoc:

      ApiAuth.register_driver 'ActionDispatch::Request', self
      if defined? ActionDispatch
        ApiAuth.register_driver 'ActionController::TestRequest', self
      end

      def request_uri
        @request.fullpath
      end
    end
  end
end
