# frozen_string_literal: true
#
# ronin-listener-http - A HTTP server for receiving exfiltrated data.
#
# Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)
#
# ronin-listener-http is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-listener-http is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-listener-http.  If not, see <https://www.gnu.org/licenses/>.
#

require_relative 'request'

require 'async'
require 'async/http/server'
require 'async/http/endpoint'
require 'async/http/protocol/response'
require 'protocol/http/reference'

module Ronin
  module Listener
    module HTTP
      #
      # A simple HTTP server that receives exfiltrated HTTP requests.
      #
      class Server < Async::HTTP::Server

        # The host the server will listen on.
        #
        # @return [String]
        attr_reader :host

        # The port the server will listen on.
        #
        # @return [Integer]
        attr_reader :port

        # The virtual host (vhost) to filter requests with.
        #
        # @return [String, Regexp, nil]
        attr_reader :vhost

        # The root directory to filter requests with.
        #
        # @return [String]
        attr_reader :root

        # The callback which will be passed all received queries.
        #
        # @return [Proc]
        #
        # @api private
        attr_reader :callback

        #
        # Initializes the HTTP listener server.
        #
        # @param [String] host
        #   The interface to listen on.
        #
        # @param [Integer] port
        #   The local port to listen on.
        #
        # @param [String, Regexp] vhost
        #   The virtual host (vhost) to filter requests with.
        #
        # @param [String] root
        #   The root directory to filter requests with. Defaults to `/`.
        #
        # @yield [request]
        #   The given block will be passed each received HTTP request.
        #
        # @yieldparam [Request] request
        #   The received HTTP request object.
        #
        # @raise [ArgumentError]
        #   No callback block was given.
        #
        def initialize(host:  '0.0.0.0',
                       port:  80,
                       vhost: nil,
                       root:  '/',
                       &callback)
          unless callback
            raise(ArgumentError,"#{self.class}#initialize requires a callback block")
          end

          @host = host
          @port = port

          # filtering options
          @vhost = vhost
          @root  = if root.end_with?('/') then root
                   else                        "#{root}/"
                   end

          @callback = callback

          endpoint = Async::HTTP::Endpoint.parse("http://#{host}:#{port}")

          super(method(:process),endpoint)
        end

        #
        # Runs the HTTP server.
        #
        def run(*args)
          Async::Reactor.run do |task|
            super(*args)
          end
        end

        #
        # Processes a received request.
        #
        # @param [Async::HTTP::Protocol::HTTP1::Request,
        #         Async::HTTP::Protocol::HTTP2::Request] request
        #
        # @return [Protocol::HTTP::Response]
        #
        def process(request)
          if (@vhost.nil? || @vhost === request.authority)
            reference = Protocol::HTTP::Reference.parse(request.path)
            path      = reference.path

            if path == @root || path.start_with?(@root)
              @callback.call(
                Request.new(
                  remote_addr: request.remote_address,
                  method:      request.method,
                  path:        path,
                  query:       reference.query,
                  version:     request.version,
                  headers:     request.headers,
                  body:        request.body
                )
              )
            end
          end

          return Protocol::HTTP::Response[404, {}, ["Not Found"]]
        end

      end
    end
  end
end
