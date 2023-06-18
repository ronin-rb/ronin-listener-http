require 'spec_helper'
require 'ronin/listener/http/server'

describe Ronin::Listener::HTTP::Server do
  let(:host)     { '127.0.0.1' }
  let(:port)     { 8080 }
  let(:vhost)    { 'example.com' }
  let(:root)     { '/dir/' }
  let(:callback) { ->(request) {} }

  subject { described_class.new(&callback) }

  describe "#initialize" do
    it "must default #host to '0.0.0.0'" do
      expect(subject.host).to eq('0.0.0.0')
    end

    it "must default #port to 80" do
      expect(subject.port).to eq(80)
    end

    it "must default #vhost to nil" do
      expect(subject.vhost).to be(nil)
    end

    it "must default #root to '/'" do
      expect(subject.root).to eq('/')
    end

    it "must set #callback" do
      expect(subject.callback).to be(callback)
    end

    context "when given the host: keyword argument" do
      subject { described_class.new(host: host, &callback) }

      it "must set #host" do
        expect(subject.host).to eq(host)
      end
    end

    context "when given the port: keyword argument" do
      subject { described_class.new(port: port, &callback) }

      it "must set #port" do
        expect(subject.port).to eq(port)
      end
    end

    context "when given the vhost: keyword argument" do
      subject { described_class.new(vhost: vhost, &callback) }

      it "must set #vhost" do
        expect(subject.vhost).to eq(vhost)
      end
    end

    context "when given the root: keyword argument" do
      subject { described_class.new(root: root, &callback) }

      it "must set #root" do
        expect(subject.root).to eq(root)
      end

      context "when the root: value does not end with a '/' character" do
        let(:root) { "/dir" }

        it "must append a '/' character to the #root" do
          expect(subject.root).to eq("#{root}/")
        end
      end
    end

    context "when no block is given" do
      it do
        expect {
          described_class.new
        }.to raise_error(ArgumentError,"#{described_class}#initialize requires a callback block")
      end
    end
  end

  describe "#process" do
    context "when #vhost is nil" do
      context "and #root is '/'" do
        let(:http_request1) do
          double('Async HTTP request1', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'host1.com',
                                        headers:   {'Host' => 'host1.com'},
                                        body:      nil)
        end

        let(:http_request2) do
          double('Async HTTP request2', method:    'GET',
                                        path:      '/foo',
                                        version:   '1.1',
                                        authority: 'host2.com',
                                        headers:   {'Host' => 'host2.com'},
                                        body:      nil)
        end

        let(:yielded_request1) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request1.method,
            version: http_request1.version,
            headers: http_request1.headers,
            path:    http_request1.path
          )
        end

        let(:yielded_request2) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request2.method,
            version: http_request2.version,
            headers: http_request2.headers,
            path:    http_request2.path
          )
        end

        it "must call the #callback with any received request" do
          expect { |b|
            server = described_class.new(&b)
            server.process(http_request1)
            server.process(http_request2)
          }.to yield_successive_args(yielded_request1,yielded_request2)
        end
      end

      context "and #root is not '/'" do
        let(:http_request1) do
          double('Async HTTP request1', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'host1.com',
                                        headers:   {'Host' => 'host1.com'},
                                        body:      nil)
        end

        let(:http_request2) do
          double('Async HTTP request2', method:    'GET',
                                        path:      '/dir/',
                                        version:   '1.1',
                                        authority: 'host2.com',
                                        headers:   {'Host' => 'host2.com'},
                                        body:      nil)
        end

        let(:http_request3) do
          double('Async HTTP request3', method:    'GET',
                                        path:      '/dir/foo',
                                        version:   '1.1',
                                        authority: 'host3.com',
                                        headers:   {'Host' => 'host3.com'},
                                        body:      nil)
        end

        let(:yielded_request1) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request2.method,
            version: http_request2.version,
            headers: http_request2.headers,
            path:    http_request2.path
          )
        end

        let(:yielded_request2) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request3.method,
            version: http_request3.version,
            headers: http_request3.headers,
            path:    http_request3.path
          )
        end

        let(:root) { '/dir/' }

        it "must call the #callback only with requests requests with a path that start with #root" do
          expect { |b|
            server = described_class.new(root: root, &b)
            server.process(http_request1)
            server.process(http_request2)
            server.process(http_request3)
          }.to yield_successive_args(yielded_request1,yielded_request2)
        end
      end
    end

    context "when #vhost is a String" do
      let(:vhost) { 'example.com' }

      context "and #root is '/'" do
        let(:http_request1) do
          double('Async HTTP request1', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'other.com',
                                        headers:   {'Host' => 'other.com'},
                                        body:      nil)
        end

        let(:http_request2) do
          double('Async HTTP request2', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'example.com',
                                        headers:   {'Host' => 'example.com'},
                                        body:      nil)
        end

        let(:http_request3) do
          double('Async HTTP request3', method:    'GET',
                                        path:      '/foo',
                                        version:   '1.1',
                                        authority: 'example.com',
                                        headers:   {'Host' => 'example.com'},
                                        body:      nil)
        end

        let(:yielded_request1) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request2.method,
            version: http_request2.version,
            headers: http_request2.headers,
            path:    http_request2.path
          )
        end

        let(:yielded_request2) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request3.method,
            version: http_request3.version,
            headers: http_request3.headers,
            path:    http_request3.path
          )
        end

        it "must call the #callback only with requests with matching Host headers" do
          expect { |b|
            server = described_class.new(vhost: vhost, &b)
            server.process(http_request1)
            server.process(http_request2)
            server.process(http_request3)
          }.to yield_successive_args(yielded_request1,yielded_request2)
        end
      end

      context "and #root is not '/'" do
        let(:http_request1) do
          double('Async HTTP request1', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'other.com',
                                        headers:   {'Host' => 'other.com'},
                                        body:      nil)
        end

        let(:http_request2) do
          double('Async HTTP request2', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'example.com',
                                        headers:   {'Host' => 'example.com'},
                                        body:      nil)
        end

        let(:http_request3) do
          double('Async HTTP request3', method:    'GET',
                                        path:      '/dir/foo',
                                        version:   '1.1',
                                        authority: 'example.com',
                                        headers:   {'Host' => 'example.com'},
                                        body:      nil)
        end

        let(:yielded_request) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request3.method,
            version: http_request3.version,
            headers: http_request3.headers,
            path:    http_request3.path
          )
        end

        let(:root) { "/dir/" }

        it "must call the #callback only with requests with matching Host headers and with a path that start with #root" do
          expect { |b|
            server = described_class.new(vhost: vhost, root: root, &b)
            server.process(http_request1)
            server.process(http_request2)
            server.process(http_request3)
          }.to yield_successive_args(yielded_request)
        end
      end
    end

    context "when #vhost is a Regexp" do
      let(:vhost) { /\.example\.com\z/ }

      context "and #root is '/'" do
        let(:http_request1) do
          double('Async HTTP request1', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'other.com',
                                        headers:   {'Host' => 'other.com'},
                                        body:      nil)
        end

        let(:http_request2) do
          double('Async HTTP request2', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'foo.example.com',
                                        headers:   {'Host' => 'foo.example.com'},
                                        body:      nil)
        end

        let(:http_request3) do
          double('Async HTTP request3', method:    'GET',
                                        path:      '/foo',
                                        version:   '1.1',
                                        authority: 'bar.example.com',
                                        headers:   {'Host' => 'bar.example.com'},
                                        body:      nil)
        end

        let(:yielded_request1) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request2.method,
            version: http_request2.version,
            headers: http_request2.headers,
            path:    http_request2.path
          )
        end

        let(:yielded_request2) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request3.method,
            version: http_request3.version,
            headers: http_request3.headers,
            path:    http_request3.path
          )
        end

        it "must call the #callback only with requests with matching Host headers" do
          expect { |b|
            server = described_class.new(vhost: vhost, &b)
            server.process(http_request1)
            server.process(http_request2)
            server.process(http_request3)
          }.to yield_successive_args(yielded_request1,yielded_request2)
        end
      end

      context "and #root is not '/'" do
        let(:http_request1) do
          double('Async HTTP request1', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'other.com',
                                        headers:   {'Host' => 'bar.example.com'},
                                        body:      nil)
        end

        let(:http_request2) do
          double('Async HTTP request2', method:    'GET',
                                        path:      '/',
                                        version:   '1.1',
                                        authority: 'foo.example.com',
                                        headers:   {'Host' => 'bar.example.com'},
                                        body:      nil)
        end

        let(:http_request3) do
          double('Async HTTP request3', method:    'GET',
                                        path:      '/dir/foo',
                                        version:   '1.1',
                                        authority: 'bar.example.com',
                                        headers:   {'Host' => 'bar.example.com'},
                                        body:      nil)
        end

        let(:yielded_request) do
          Ronin::Listener::HTTP::Request.new(
            method:  http_request3.method,
            version: http_request3.version,
            headers: http_request3.headers,
            path:    http_request3.path
          )
        end

        let(:root) { "/dir/" }

        it "must call the #callback only with requests with matching Host headers and requests with a path that start with #root" do
          expect { |b|
            server = described_class.new(vhost: vhost, root: root, &b)
            server.process(http_request1)
            server.process(http_request2)
            server.process(http_request3)
          }.to yield_successive_args(yielded_request)
        end
      end
    end
  end
end
