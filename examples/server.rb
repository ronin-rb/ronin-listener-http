#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'ronin/listener/http'

puts "Listening on 127.0.0.1:8080 ..."
puts "Try sending requests to http://localhost:8080/ to test"

begin
  Ronin::Listener::HTTP.listen(host: '127.0.0.1', port: 8080) do |request|
    puts "#{request.method} #{request.path} #{request.version}"

    request.headers.each do |name,value|
      puts "#{name}: #{value}"
    end

    puts request.body if request.body
    puts
  end
rescue Interrupt
  exit(127)
end
