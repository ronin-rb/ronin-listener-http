require 'spec_helper'
require 'ronin/exfil/http/server'

describe Ronin::Exfil::HTTP::Server do
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
        let(:request1) do
          double('Async HTTP request1', authority: 'host1.com',
                                        path: '/')
        end

        let(:request2) do
          double('Async HTTP request2', authority: 'host2.com',
                                        path: '/foo')
        end

        it "must call the #callback with any received request" do
          expect { |b|
            server = described_class.new(&b)
            server.process(request1)
            server.process(request2)
          }.to yield_successive_args(request1,request2)
        end
      end

      context "and #root is not '/'" do
        let(:request1) do
          double('Async HTTP request1', authority: 'host1.com',
                                        path: '/')
        end

        let(:request2) do
          double('Async HTTP request2', authority: 'host2.com',
                                        path: '/dir/')
        end

        let(:request3) do
          double('Async HTTP request3', authority: 'host3.com',
                                        path: '/dir/foo')
        end

        let(:root) { '/dir/' }

        it "must call the #callback only with requests requests with a path that start with #root" do
          expect { |b|
            server = described_class.new(root: root, &b)
            server.process(request1)
            server.process(request2)
            server.process(request3)
          }.to yield_successive_args(request2,request3)
        end
      end
    end

    context "when #vhost is a String" do
      let(:vhost) { 'example.com' }

      context "and #root is '/'" do
        let(:request1) do
          double('Async HTTP request1', authority: 'other.com',
                                        path: '/')
        end

        let(:request2) do
          double('Async HTTP request2', authority: 'example.com',
                                        path: '/')
        end

        let(:request3) do
          double('Async HTTP request3', authority: 'example.com',
                                        path: '/foo')
        end

        it "must call the #callback only with requests with matching Host headers" do
          expect { |b|
            server = described_class.new(vhost: vhost, &b)
            server.process(request1)
            server.process(request2)
            server.process(request3)
          }.to yield_successive_args(request2,request3)
        end
      end

      context "and #root is not '/'" do
        let(:request1) do
          double('Async HTTP request1', authority: 'other.com',
                                        path: '/')
        end

        let(:request2) do
          double('Async HTTP request2', authority: 'example.com',
                                        path: '/')
        end

        let(:request3) do
          double('Async HTTP request3', authority: 'example.com',
                                        path: '/dir/foo')
        end

        let(:root) { "/dir/" }

        it "must call the #callback only with requests with matching Host headers and with a path that start with #root" do
          expect { |b|
            server = described_class.new(vhost: vhost, root: root, &b)
            server.process(request1)
            server.process(request2)
            server.process(request3)
          }.to yield_successive_args(request3)
        end
      end
    end

    context "when #vhost is a Regexp" do
      let(:vhost) { /\.example\.com\z/ }

      context "and #root is '/'" do
        let(:request1) do
          double('Async HTTP request1', authority: 'other.com',
                                        path: '/')
        end

        let(:request2) do
          double('Async HTTP request2', authority: 'foo.example.com',
                                        path: '/')
        end

        let(:request3) do
          double('Async HTTP request3', authority: 'bar.example.com',
                                        path: '/foo')
        end

        it "must call the #callback only with requests with matching Host headers" do
          expect { |b|
            server = described_class.new(vhost: vhost, &b)
            server.process(request1)
            server.process(request2)
            server.process(request3)
          }.to yield_successive_args(request2,request3)
        end
      end

      context "and #root is not '/'" do
        let(:request1) do
          double('Async HTTP request1', authority: 'other.com',
                                        path: '/')
        end

        let(:request2) do
          double('Async HTTP request2', authority: 'foo.example.com',
                                        path: '/')
        end

        let(:request3) do
          double('Async HTTP request3', authority: 'bar.example.com',
                                        path: '/dir/foo')
        end

        let(:root) { "/dir/" }

        it "must call the #callback only with requests with matching Host headers and requests with a path that start with #root" do
          expect { |b|
            server = described_class.new(vhost: vhost, root: root, &b)
            server.process(request1)
            server.process(request2)
            server.process(request3)
          }.to yield_successive_args(request3)
        end
      end
    end
  end
end
