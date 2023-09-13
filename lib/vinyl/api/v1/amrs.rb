module Vinyl
  module API
    # AmrV1 is the v1 of Vinyl's audible magic endpoints
    class AmrV1
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def create_amr(vod_id:, amr_fields:)
        path = "/v1/amrs"

        body = Hash.new
        body["audible_magic_responses"] = amr_fields

        begin
          response = client.post(path, body)
        rescue Faraday::Error::ResourceNotFound
          return nil
        end

        response
      end

      def get_for_vod(vod_id:)
        path = "/v1/amrs?vod_id=#{vod_id}"

        begin
          response = client.get(path)
        rescue Faraday::Error::ResourceNotFound
          return nil
        end

        response
      end

      def update_amr(amr_id:, amr_fields:)
        path = "/v1/amrs/#{amr_id}"

        begin
          response = client.put(path, amr_fields)
        rescue Faraday::Error::ResourceNotFound
          return nil
        end

        response
      end

    end
  end
end
