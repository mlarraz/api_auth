module ApiAuth
  module RequestDrivers # :nodoc:
    class FaradayRequest # :nodoc:
      include ApiAuth::Helpers

      def initialize(request)
        @request = request
        fetch_headers
        true
      end

      def set_auth_header(header)
        set_header('Authorization', header)
        @request
      end

      def calculated_md5
        body = @request.body ? @request.body : ''
        md5_base64digest(body)
      end

      def populate_content_md5
        return unless %w[POST PUT].include?(@request.method.to_s.upcase)
        set_header('Content-MD5', calculated_md5)
      end

      def md5_mismatch?
        if %w[POST PUT].include?(@request.method.to_s.upcase)
          calculated_md5 != content_md5
        else
          false
        end
      end

      def fetch_headers
        @headers = capitalize_keys @request.headers
      end

      def http_method
        @request.method.to_s.upcase
      end

      def content_type
        find_header(%w[CONTENT-TYPE CONTENT_TYPE HTTP_CONTENT_TYPE])
      end

      def content_md5
        find_header(%w[CONTENT-MD5 CONTENT_MD5 HTTP-CONTENT-MD5 HTTP_CONTENT_MD5])
      end

      def original_uri
        find_header(%w[X-ORIGINAL-URI X_ORIGINAL_URI HTTP_X_ORIGINAL_URI])
      end

      def request_uri
        query_string = @request.params.to_query
        query_string = nil if query_string.empty?
        uri = URI::HTTP.new(nil, nil, nil, nil, nil, @request.path, nil, query_string, nil)
        uri.to_s
      end

      def set_date
        set_header('DATE', Time.now.utc.httpdate)
      end

      def timestamp
        find_header(%w[DATE HTTP_DATE])
      end

      def authorization_header
        find_header %w[Authorization AUTHORIZATION HTTP_AUTHORIZATION]
      end

      private

      def find_header(keys)
        keys.map { |key| @headers[key] }.compact.first
      end

      def set_header(key, value)
        @request.headers[key] = value
        fetch_headers
      end
    end

    class FaradayEnv < FaradayRequest # :nodoc:
      def fetch_headers
        @headers = capitalize_keys @request.request_headers
      end

      def request_uri
        @request.url.request_uri
      end

      private

      def set_header(key, value)
        @request.request_headers[key] = value
        fetch_headers
      end
    end
  end
end
