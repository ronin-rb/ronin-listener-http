require 'spec_helper'
require 'ronin/listener/http/request'

describe Ronin::Listener::HTTP::Request do
  let(:method)  { 'GET' }
  let(:path)    { '/' }
  let(:version) { '1.1' }
  let(:headers) { {'Host' => 'host1.com'} }
  let(:body)    { "foo bar" }

  subject do
    described_class.new(
      method:  method,
      path:    path,
      version: version,
      headers: headers,
      body:    body
    )
  end

  describe "#initialize" do
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
  end

  describe "#==" do
    context "when given a #{described_class}" do
      context "and all attributes are the same" do
        let(:other) do
          described_class.new(
            method:  method,
            path:    path,
            version: version,
            headers: headers,
            body:    body
          )
        end

        it "must return true" do
          expect(subject == other).to be(true)
        end
      end

      context "but the #method is different" do
        let(:other) do
          described_class.new(
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

      context "but the #path is different" do
        let(:other) do
          described_class.new(
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
end
