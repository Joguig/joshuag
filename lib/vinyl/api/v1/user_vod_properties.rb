module Vinyl
  module API
    # UserVodProperties is the v1 of Vinyl's UserVodProperties endpoints
    class UserVodPropertiesV1
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def get(user_id:)
        client.get("/v1/user_vod_properties/#{user_id}")
      end

      def set(user_id:, properties:)
        path = "/v1/user_vod_properties/#{user_id}"

        begin
          response = client.put(path, properties)
        rescue Faraday::Error::ClientError => err
          # pass back Vinyl error through to rails.
          response = err.response[:body]
          return JSON.parse(response)
        end
      end
    end
  end
end
