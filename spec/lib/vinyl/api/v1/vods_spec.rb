require 'spec_helper'
require 'faraday'

describe Vinyl::API::VodV1 do
  let(:client) { double('Vinyl::Client') }
  let(:subject) { Vinyl::API::VodV1.new(client) }
  let(:user_id) { 10 }

  describe :get_by_status do
    context 'is successful' do
      before do
        expect(client).to receive(:get)
        .with("/v1/vods/status/unprocessed?broadcast_type=highlight&start_time=1465419990&end_time=1465429990")
        .and_return([
          { 'api_id' => 1, 'owner_id' => 10, 'broadcast_type' => 'archive' },
          { 'api_id' => 2, 'owner_id' => 10, 'broadcast_type' => 'archive' },
        ])
      end

      it 'returns vods' do
        vods = subject.get_by_status(status: "unprocessed", broadcast_type: "highlight", start_time: 1465419990, end_time: 1465429990)
        expect(vods[0]['api_id']).to eq(1)
      end
    end

    context 'returns a 404' do
      before do
        expect(client).to receive(:get)
        .with("/v1/vods/status/unprocessed?")
        .and_raise(Faraday::Error::ResourceNotFound, '')
      end

      it 'returns nil when a vod is not found' do
        vods = subject.get_by_status(status: "unprocessed")
        expect(vods.length).to eq(0)
      end
    end
  end

  describe :get_by_ids do
    let(:vod_ids) { [1, 2] }
    let(:appeals_and_amrs) { true }
    let(:notification_settings) { true }
    context 'is successful' do
      before do
        expect(client).to receive(:get)
          .with('/v1/vods?ids=1,2&appeals_and_amrs=true&notification_settings=true&include_deleted=true&include_private=false&include_processing=true')
          .and_return([
            { 'api_id' => 1, 'owner_id' => 10, 'broadcast_type' => 'archive' },
            { 'api_id' => 2, 'owner_id' => 10, 'broadcast_type' => 'archive' },
          ])
      end

      it 'returns vods' do
        vods = subject.get_by_ids(vod_ids: vod_ids, appeals_and_amrs: appeals_and_amrs, notification_settings: notification_settings, filters: {
          include_deleted: true,
          include_private: false,
          include_processing: true
        })
        expect(vods[0]['api_id']).to eq(1)
      end
    end

    context 'returns a 404' do
      before do
        expect(client).to receive(:get)
          .with('/v1/vods?ids=1,2&appeals_and_amrs=true&notification_settings=true&include_deleted=true&include_private=false&include_processing=true')
          .and_raise(Faraday::Error::ResourceNotFound, '')
      end

      it 'returns nil when a vod is not found' do
        vods = subject.get_by_ids(vod_ids: vod_ids, appeals_and_amrs: appeals_and_amrs, notification_settings: notification_settings, filters: {
          include_deleted: true,
          include_private: false,
          include_processing: true
        })
        expect(vods['error']).to include('Client error while fetching vods by IDs')
      end
    end
  end

  describe :top do
    context 'is successful' do
      before do
        expect(client).to receive(:get)
          .with("/v1/vods/top?broadcast_type=highlight&game=Hearthstone&period=week&language=&sort=views&limit=20&offset=0", timeout: 5 * 1000)
          .and_return([
            { 'api_id' => 1, 'owner_id' => 10, 'broadcast_type' => 'archive' },
            { 'api_id' => 2, 'owner_id' => 10, 'broadcast_type' => 'archive' },
          ])
      end

      it 'returns vods' do
        vods = subject.top(broadcast_type: 'highlight', game: 'Hearthstone', period: 'week', language: '', sort: 'views', limit: 20, offset: 0, timeout: 5 * 1000)
        expect(vods[0]['api_id']).to eq(1)
      end

    end

    context 'invalid broadcast_type' do
      before do
        expect(client).to receive(:get)
          .with("/v1/vods/top?broadcast_type=lol&game=Hearthstone&period=week&language=&sort=views&limit=20&offset=0", timeout: 5 * 1000)
          .and_raise(Faraday::Error::ClientError, '')
      end

      it 'returns nil when vods are not found' do
        expect do
          subject.top(broadcast_type: 'lol', game: 'Hearthstone', period: 'week', language: '', sort: 'views', limit: 20, offset: 0, timeout: 5 * 1000)
        end.to raise_error(Faraday::Error::ClientError)
      end
    end
  end

  describe :delete do
    let(:vod_ids) { [1, 2] }

    it "makes a DELETE request to vinyl" do
      expect(client).to receive(:delete)
        .with("/v1/vods?ids=1,2&destructive=false")

      subject.delete(vod_ids: vod_ids, destroy: false)
    end

    it "supports destructive deletions using vinyl" do
      expect(client).to receive(:delete)
      .with("/v1/vods?ids=1,2&destructive=true")

      subject.delete(vod_ids: vod_ids, destroy: true)
    end
  end

  describe :destroy_all_for_user do
    let(:user_id) { 456 }

    it "makes a DELETE request to vinyl" do
      expect(client).to receive(:delete)
        .with("/v1/users/#{user_id}/vods")

      subject.destroy_all_for_user(user_id: user_id)
    end

    it "returns a response with an error when an request error happens" do
      expect(client).to receive(:delete)
        .with("/v1/users/#{user_id}/vods")
        .and_raise(Faraday::Error::ClientError.new(StandardError.new("Nothing"), { body: "{\"error\": \"What an error!\"}" }))

      ctx = subject.destroy_all_for_user(user_id: user_id)
      expect(ctx["error"]).to eq("What an error!")
    end
  end

  describe :update do
    let(:vod_id) { 1 }
    let(:options) { {} }
    let(:thumb_index) { 1 }
    let(:new_thumbnail_path) { "/thumbs/file.jpg" }

    it "makes a successful UPDATE request to vinyl" do
      expect(client).to receive(:put)
        .with("/v1/vods/1", {})

      subject.update(vod_id: vod_id, options: options)
    end
  end
end
