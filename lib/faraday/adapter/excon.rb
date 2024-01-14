# frozen_string_literal: true

module Faraday
  class Adapter
    # Excon adapter.
    class Excon < Faraday::Adapter
      def build_connection(env)
        if @connection_options[:persistent] && defined?(@connection)
          return @connection
        end

        opts = opts_from_env(env)

        # remove path & query when creating connection
        # because if it is persistent, it can re-use the conn
        url = env[:url].dup
        url.path = ''
        url.query = nil

        @connection = ::Excon.new(url.to_s, opts.merge(@connection_options))
      end

      def call(env)
        super

        req_opts = {
          path: env[:url].path,
          query: env[:url].query,
          method: env[:method].to_s.upcase,
          headers: env[:request_headers],
          body: read_body(env)
        }

        req = env[:request]
        if req&.stream_response?
          total = 0
          req_opts[:response_block] = lambda do |chunk, _remain, _total|
            req.on_data.call(chunk, total += chunk.size)
          end
        end

        resp = connect_and_request(env, req_opts)
        save_response(env, resp.status.to_i, resp.body, resp.headers,
                      resp.reason_phrase)

        @app.call(env)
      end

      # TODO: support streaming requests
      def read_body(env)
        env[:body].respond_to?(:read) ? env[:body].read : env[:body]
      end

      private

      def connect_and_request(env, req_opts)
        connection(env) { |http| http.request(req_opts) }
      rescue ::Excon::Errors::SocketError => e
        raise Faraday::TimeoutError, e if e.message.match?(/\btimeout\b/)

        raise Faraday::SSLError, e if e.message.match?(/\bcertificate\b/)

        raise Faraday::ConnectionFailed, e
      rescue ::Excon::Errors::Timeout => e
        raise Faraday::TimeoutError, e
      end

      def opts_from_env(env)
        opts = {}
        amend_opts_with_ssl!(opts, env[:ssl]) if needs_ssl_settings?(env)

        if (req = env[:request])
          amend_opts_with_timeouts!(opts, req)
          amend_opts_with_proxy_settings!(opts, req)
        end

        opts
      end

      def needs_ssl_settings?(env)
        env[:url].scheme == 'https' && env[:ssl]
      end

      OPTS_KEYS = [
        %i[client_cert client_cert],
        %i[client_key client_key],
        %i[certificate certificate],
        %i[private_key private_key],
        %i[ssl_ca_path ca_path],
        %i[ssl_ca_file ca_file],
        %i[ssl_version version],
        %i[ssl_min_version min_version],
        %i[ssl_max_version max_version]
      ].freeze

      def amend_opts_with_ssl!(opts, ssl)
        opts[:ssl_verify_peer] = !!ssl.fetch(:verify, true)
        # https://github.com/geemus/excon/issues/106
        # https://github.com/jruby/jruby-ossl/issues/19
        opts[:nonblock] = false

        OPTS_KEYS.each do |(key_in_opts, key_in_ssl)|
          next unless ssl[key_in_ssl]

          opts[key_in_opts] = ssl[key_in_ssl]
        end
      end

      def amend_opts_with_timeouts!(opts, req)
        if (sec = request_timeout(:read, req))
          opts[:read_timeout] = sec
        end

        if (sec = request_timeout(:write, req))
          opts[:write_timeout] = sec
        end

        return unless (sec = request_timeout(:open, req))

        opts[:connect_timeout] = sec
      end

      def amend_opts_with_proxy_settings!(opts, req)
        opts[:proxy] = proxy_settings_for_opts(req[:proxy]) if req[:proxy]
      end

      def proxy_settings_for_opts(proxy)
        {
          host: proxy[:uri].host,
          hostname: proxy[:uri].hostname,
          port: proxy[:uri].port,
          scheme: proxy[:uri].scheme,
          user: proxy[:user],
          password: proxy[:password]
        }
      end
    end
  end
end
