require 'spec_helper'
require 'faraday'

describe Vinyl::API::UserVodPropertiesV1 do
  let(:client) { double('Vinyl::Client') }
  let(:subject) { Vinyl::API::UserVodPropertiesV1.new(client) }
  let(:user_id) { 10 }

  describe :get do
    context 'is successful' do
      before do
        expect(client).to receive(:get)
        .with("/v1/user_vod_properties/#{user_id}")
        .and_return({
          'properties' => {
            'user_id' => 1,
            'save_vods_forever' => true
          }
        })
      end

      it 'returns vods' do
        vods = subject.get(user_id: user_id)
        expect(vods['properties']['user_id']).to eq(1)
      end
    end
  end

  describe :set do
    context 'is successful' do
      let(:props) { {"save_vods_forever" => true} }
      before do
        expect(client).to receive(:put)
        .with("/v1/user_vod_properties/#{user_id}", props)
        .and_return({
          'properties' => {
            'user_id' => 1,
            'save_vods_forever' => true
          }
        })
      end

      it 'returns vods' do
        vods = subject.set(user_id: user_id, properties: props)
        expect(vods['properties']['user_id']).to eq(1)
      end
    end
  end
end
