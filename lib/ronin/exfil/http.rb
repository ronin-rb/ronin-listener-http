# frozen_string_literal: true
#
# ronin-exfil-http - A HTTP server for receiving exfiltrated data.
#
# Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)
#
# ronin-exfil-http is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-exfil-http is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-exfil-http.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/exfil/http/server'

module Ronin
  module Exfil
    #
    # Top-level methods for {Ronin::Exfil::HTTP}.
    #
    module HTTP
      #
      # Starts the HTTP exfil server.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {Server#initialize}.
      #
      # @option kwargs [String] :host ('0.0.0.0')
      #   The interface to listen on.
      #
      # @option kwargs [Integer] :port (80)
      #   The local port to listen on.
      #
      # @option kwargs [String, Regexp] :vhost
      #   The virtual host (vhost) to filter requests with.
      #
      # @option kwargs [String] :root ('/')
      #   The root directory to filter requests with. Defaults to `/`.
      #
      # @yield [request]
      #   The given block will be passed each received HTTP request.
      #
      # @yieldparam [Async::HTTP::Protocol::HTTP1::Request,
      #              Async::HTTP::Protocol::HTTP2::Request] request
      #   The received HTTP request object.
      #
      # @raise [ArgumentError]
      #   No callback block was given.
      #
      def self.listen(**kwargs,&callback)
        server = Server.new(**kwargs,&callback)
        server.run
      end
    end
  end
end
