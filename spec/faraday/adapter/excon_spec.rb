# frozen_string_literal: true

RSpec.describe Faraday::Adapter::Excon do
  features :compression,
           :reason_phrase_parse,
           :request_body_on_query_methods,
           :trace_method

  it_behaves_like 'an adapter'

  it 'allows to provide adapter specific configs' do
    url = URI('https://example.com:1234')

    adapter = described_class.new(nil, debug_request: true)

    conn = adapter.build_connection(url: url)

    expect(conn.data[:debug_request]).to be_truthy
  end

  context 'when building connection' do
    let(:adapter) { described_class.new }
    let(:request) { Faraday::RequestOptions.new }
    let(:uri) { URI.parse('https://example.com') }
    let(:env) { { request: request, url: uri } }

    it 'uses a new connection when the adapter is not persistent' do
      conn1 = adapter.connection(env)
      expect(adapter.connection(env)).not_to be(conn1)
    end

    it 're-uses the same connection when the adapter is persistent' do
      adapter = described_class.new(nil, persistent: true)
      conn1 = adapter.connection(env)
      expect(adapter.connection(env)).to be(conn1)
    end
  end

  context 'with config' do
    let(:adapter) { described_class.new }
    let(:request) { Faraday::RequestOptions.new }
    let(:uri) { URI.parse('https://example.com') }
    let(:env) { { request: request, url: uri } }

    context 'with timeout' do
      it 'sets read_timeout' do
        request.timeout = 5
        options = adapter.send(:opts_from_env, env)
        expect(options[:read_timeout]).to eq(5)
      end

      it 'sets write_timeout' do
        request.timeout = 5
        options = adapter.send(:opts_from_env, env)
        expect(options[:write_timeout]).to eq(5)
      end

      it 'sets connect_timeout' do
        request.timeout = 5
        options = adapter.send(:opts_from_env, env)
        expect(options[:connect_timeout]).to eq(5)
      end
    end

    context 'with open_timeout' do
      it 'does not set read_timeout' do
        request.open_timeout = 3
        options = adapter.send(:opts_from_env, env)
        expect(options[:read_timeout]).to be_nil
      end

      it 'does not set write_timeout' do
        request.open_timeout = 3
        options = adapter.send(:opts_from_env, env)
        expect(options[:write_timeout]).to be_nil
      end

      it 'sets connect_timeout' do
        request.open_timeout = 3
        options = adapter.send(:opts_from_env, env)
        expect(options[:connect_timeout]).to eq(3)
      end
    end
  end
end
