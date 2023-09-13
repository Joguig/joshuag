module Vinyl
  module API
    class ThumbnailsV1
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def create(vod_id:, thumbnails:)
        path = "/v1/vods/#{vod_id}/thumbnails"

        body = Hash.new
        body["thumbnails"] = thumbnails

        begin
          response = client.post(path, body)
        rescue Faraday::Error::ClientError => err
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to create thumbnails"}
        end

        response
      end

      def delete(vod_id:, path:)
        path = "/v1/vods/#{vod_id}/thumbnails?path=#{path}"

        begin
          response = client.delete(path)
        rescue Faraday::Error::ClientError => err
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to delete thumbnail"}
        end

        response
      end
    end
  end
end
