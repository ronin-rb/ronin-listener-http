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

require_relative 'http/server'

module Ronin
  module Listener
    #
    # Top-level methods for {Ronin::Listener::HTTP}.
    #
    module HTTP
      #
      # Starts the HTTP listener server.
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
      # @yieldparam [Request] request
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
