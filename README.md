# ronin-exfil-http

[![CI](https://github.com/ronin-rb/ronin-exfil-http/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-exfil-http/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-exfil-http.svg)](https://codeclimate.com/github/ronin-rb/ronin-exfil-http)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-exfil-http)
* [Issues](https://github.com/ronin-rb/ronin-exfil-http/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-exfil-http)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Twitter](https://twitter.com/ronin_rb) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-exfil-http is a DNS server for receiving exfiltrated data sent via HTTP
requests. ronin-exfil-http can be used to test for Server-Side Request Forgery
(SSRF) or XML external entity (XXE) injection.

## Features

* Supports receiving HTTP requests.
* Supports filtering HTTP requests by path or `Host` header.

## Examples

```ruby
Ronin::Exfil::HTTP.listen(host: '127.0.0.1', port: 8080) do |request|
  puts "#{request.method} #{request.path}"

  request.headers.each do |name,value|
    puts "#{name}: #{value}"
  end

  puts request.body if request.body
  puts
end
```

## Requirements

* [Ruby] >= 3.0.0
* [async-http] ~> 1.0

## Install

```shell
$ gem install ronin-exfil-http
```

### Gemfile

```ruby
gem 'ronin-exfil-http', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-exfil-http', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-exfil-http/fork)
2. Clone It!
3. `cd ronin-exfil-http/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)

ronin-exfil-http is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-exfil-http is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-exfil-http.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[async-http]: https://github.com/socketry/async-http#readme
