# ronin-listener-http

[![CI](https://github.com/ronin-rb/ronin-listener-http/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-listener-http/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-listener-http.svg)](https://codeclimate.com/github/ronin-rb/ronin-listener-http)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-listener-http)
* [Issues](https://github.com/ronin-rb/ronin-listener-http/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-listener-http)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-listener-http is a DNS server for receiving exfiltrated data sent via HTTP
requests. ronin-listener-http can be used to test for Server-Side Request
Forgery (SSRF) or XML external entity (XXE) injection.

## Features

* Supports receiving HTTP requests.
* Supports filtering HTTP requests by path or `Host` header.

## Examples

```ruby
require 'ronin/listener/http'

Ronin::Listener::HTTP.listen(host: '127.0.0.1', port: 8080) do |request|
  puts "#{request.method} #{request.path} #{request.version}"

  request.headers.each do |name,value|
    puts "#{name}: #{value}"
  end

  puts request.body if request.body
  puts
end
```

## Requirements

* [Ruby] >= 3.2.0
* [async-http] ~> 1.0

## Install

```shell
$ gem install ronin-listener-http
```

### Gemfile

```ruby
gem 'ronin-listener-http', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-listener-http', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-listener-http/fork)
2. Clone It!
3. `cd ronin-listener-http/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)

ronin-listener-http is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-listener-http is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-listener-http.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[async-http]: https://github.com/socketry/async-http#readme
