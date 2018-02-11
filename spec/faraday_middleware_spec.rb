require 'spec_helper'
require 'api_auth/faraday_middleware'

describe ApiAuth::FaradayMiddleware do
  let(:timestamp) { Time.now.utc.httpdate }

  let(:faraday_stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.put('/resource.xml?foo=bar&bar=foo') { |env| [200, {}, env] }
      stub.get('/resource.xml?foo=bar&bar=foo') { [200, {}, ''] }
      stub.put('/resource.xml') { [200, {}, ''] }
    end
  end

  let(:faraday_conn) do
    Faraday.new do |builder|
      builder.request :api_auth, 'access_id', 'secret_key'
      builder.adapter :test, faraday_stubs
    end
  end

  let(:expected_headers) do
    {
      'Authorization' => "APIAuth access_id:12345",
      'Content-MD5' => 'kZXQvrKoieG+Be1rsZVINw==',
      'DATE' => timestamp
    }
  end

  let(:request) do
    faraday_conn.put do |request|
      request.url '/resource.xml', { 'foo': 'bar', 'bar': 'foo' }
      request.body = "hello\nworld"
    end
  end

  it 'sets the appropriate request headers' do
    expect(request.env.request_headers).to include(expected_headers)
  end
end
