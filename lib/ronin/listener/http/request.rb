# frozen_string_literal: true
#
# ronin-listener-http - A HTTP server for receiving exfiltrated data.
#
# Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'csv'
require 'json'

module Ronin
  module Listener
    module HTTP
      #
      # Represents a received HTTP request.
      #
      class Request

        # The HTTP request method.
        #
        # @return [String]
        attr_reader :method

        # The request path.
        #
        # @return [String]
        attr_reader :path

        # The HTTP version.
        #
        # @return [String]
        attr_reader :version

        # The HTTP request headers.
        #
        # @return [Hash{String => String}]
        attr_reader :headers

        # The optional request body.
        #
        # @return [String, nil]
        attr_reader :body

        #
        # Initializes the request.
        #
        # @param [String] method
        #   The HTTP request method.
        #
        # @param [String] path
        #   The request path.
        #
        # @param [String] version
        #   The HTTP version.
        #
        # @param [Hash{String => String}] headers
        #   The HTTP request headers.
        #
        # @param [String, nil] body
        #   The optional body sent with the request.
        #
        def initialize(method: , path: , version: , headers:, body: nil)
          @method  = method
          @path    = path
          @version = version
          @headers = headers
          @body    = body
        end

        #
        # Compares the request to another request.
        #
        # @param [Object] other
        #   The other object to compare to.
        #
        # @return [Boolean]
        #   Indicates if the request is equal to another request.
        #
        def ==(other)
          self.class == other.class &&
            @method  == other.method &&
            @path    == other.path &&
            @version == other.version &&
            @headers == other.headers &&
            @body    == other.body
        end

        #
        # Converts the request to a Hash.
        #
        # @return [Hash{Symbol => Object}]
        #
        def to_h
          {
            method:  @method,
            path:    @path,
            version: @version,
            headers: @headers,
            body:    @body
          }
        end

        #
        # Converts the request into a CSV line.
        #
        # @return [String]
        #   The generated CSV line.
        #
        def to_csv
          CSV.generate_line(
            [
              @method,
              @path,
              @version,
              CSV.generate { |csv|
                @headers.each_pair do |name_value|
                  csv << name_value
                end
              },
              @body
            ]
          )
        end

        alias as_json to_h

        #
        # Converts the HTTP request into JSON.
        #
        # @param [Array] args
        #   Additional arguments for `Hash#to_json`.
        #
        # @return [String]
        #   The raw JSON string.
        #
        def to_json(*args)
          as_json.to_json(*args)
        end

      end
    end
  end
end
