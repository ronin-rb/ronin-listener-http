require 'spec_helper'
require 'ronin/listener/http/request'

require 'socket'

describe Ronin::Listener::HTTP::Request do
  let(:remote_ip)   { '192.168.1.1' }
  let(:remote_port) { 1234 }
  let(:remote_addr) { Addrinfo.tcp(remote_ip,remote_port) }
  let(:method)      { 'GET' }
  let(:path)        { '/' }
  let(:query)       { 'q=1' }
  let(:version)     { '1.1' }
  let(:headers)     { {'Host' => 'host1.com'} }
  let(:body)        { "foo bar" }

  subject do
    described_class.new(
      remote_addr: remote_addr,
      method:      method,
      path:        path,
      version:     version,
      headers:     headers,
      body:        body
    )
  end

  describe "#initialize" do
    it "must set #remote_addr" do
      expect(subject.remote_addr).to eq(remote_addr)
    end

    it "must set #method" do
      expect(subject.method).to eq(method)
    end

    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must set #version" do
      expect(subject.version).to eq(version)
    end

    it "must set #headers" do
      expect(subject.headers).to eq(headers)
    end

    it "must set #body" do
      expect(subject.body).to eq(body)
    end

    context "when the query: keyword argument is not given" do
      it "must set #query to nil" do
        expect(subject.query).to be(nil)
      end
    end

    context "when the query: keyword argument is given" do
      subject do
        described_class.new(
          remote_addr: remote_addr,
          method:      method,
          path:        path,
          query:       query,
          version:     version,
          headers:     headers,
          body:        body
        )
      end

      it "must set #query" do
        expect(subject.query).to eq(query)
      end
    end
  end

  describe "#remote_ip" do
    it "must return the remote IP address String" do
      expect(subject.remote_ip).to eq(remote_ip)
    end
  end

  describe "#remote_port" do
    it "must return the remote port" do
      expect(subject.remote_port).to eq(remote_port)
    end
  end

  describe "#==" do
    context "when given a #{described_class}" do
      context "and all attributes are the same" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:      method,
            path:        path,
            version:     version,
            headers:     headers,
            body:        body
          )
        end

        it "must return true" do
          expect(subject == other).to be(true)
        end
      end

      context "but the #remote_addr is different" do
        let(:other) do
          described_class.new(
            remote_addr: Addrinfo.tcp('192.168.1.42',2345),
            method:      method,
            path:        path,
            version:     version,
            headers:     headers,
            body:        body
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end

      context "but the #method is different" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:  'POST',
            path:    path,
            version: version,
            headers: headers,
            body:    body
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end

      context "but the #path is different" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:  method,
            path:    '/different',
            version: version,
            headers: headers,
            body:    body
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end

      context "but the #query is different" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:      method,
            path:        path,
            query:       'p=1',
            version:     version,
            headers:     headers,
            body:        body
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end

      context "but the #path is different" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:  method,
            path:    path,
            version: '1.0',
            headers: headers,
            body:    body
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end

      context "but the #path is different" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:  method,
            path:    path,
            version: version,
            headers: {'X-Other' => 'different'},
            body:    body
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end

      context "but the #path is different" do
        let(:other) do
          described_class.new(
            remote_addr: remote_addr,
            method:  method,
            path:    path,
            version: version,
            headers: headers,
            body:   "different"
          )
        end

        it "must return false" do
          expect(subject == other).to be(false)
        end
      end
    end

    context "when given another kind of object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject == other).to be(false)
      end
    end
  end

  describe "#to_s" do
    it "must return a String containing the #method, #path, #version, #headers, and #body" do
      expect(subject.to_s).to eq(
        [
          "#{method} #{path} HTTP/#{version}",
          *headers.map { |name,value| "#{name}: #{value}" },
          '',
          body
        ].join("\r\n")
      )
    end

    context "when #query is set" do
      subject do
        described_class.new(
          remote_addr: remote_addr,
          method:      method,
          path:        path,
          query:       query,
          version:     version,
          headers:     headers,
          body:        body
        )
      end

      it "must append '?\#{query}' to the path of the request String" do
        expect(subject.to_s).to eq(
          [
            "#{method} #{path}?#{query} HTTP/#{version}",
            *headers.map { |name,value| "#{name}: #{value}" },
            '',
            body
          ].join("\r\n")
        )
      end
    end
  end

  describe "#to_h" do
    subject do
      described_class.new(
        remote_addr: remote_addr,
        method:      method,
        path:        path,
        query:       query,
        version:     version,
        headers:     headers,
        body:        body
      )
    end

    it "must return a Hash containing #method, #path, #query, #version, #headers, and #body" do
      expect(subject.to_h).to eq(
        {
          remote_ip:   remote_ip,
          remote_port: remote_port,
          method:      method,
          path:        path,
          query:       query,
          version:     version,
          headers:     headers,
          body:        body
        }
      )
    end
  end

  describe "#to_csv" do
    subject do
      described_class.new(
        remote_addr: remote_addr,
        method:      method,
        path:        path,
        query:       query,
        version:     version,
        headers:     headers,
        body:        body
      )
    end

    it "must convert the request into a CSV line, with the #headers as embedded CSV" do
      expect(subject.to_csv).to eq(
        CSV.generate_line(
          [
            remote_ip,
            remote_port,
            method,
            path,
            query,
            version,
            CSV.generate { |csv|
              headers.each do |name,value|
                csv << [name,value]
              end
            },
            body
          ]
        )
      )
    end
  end

  describe "#as_json" do
    it "must return #to_h" do
      expect(subject.as_json).to eq(subject.to_h)
    end
  end

  describe "#to_json" do
    it "must convert the #to_h form of the DNS query into JSON" do
      expect(subject.to_json).to eq(subject.to_h.to_json)
    end
  end
end
