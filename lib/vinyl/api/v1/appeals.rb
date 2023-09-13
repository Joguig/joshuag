module Vinyl
  module API
    # AppealV1 is the v1 of Vinyl's appeals endpoints
    class AppealV1
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def create_appeals(vod_id:, vod_appeal_params:, track_appeals:)
        path = "/v1/appeals"

        body = {
          "vod_id" => vod_id,
          "vod_appeal_params" => vod_appeal_params,
          "track_appeals" => track_appeals
        }

        begin
          response = client.post(path, body)
        rescue Faraday::Error::ResourceNotFound
          return []
        end

        response
      end

      def get_vod_appeals(priority: "", resolved: "", user_info: "", vod_id: "", limit: 10, offset: 0)
        path = "/v1/vod_appeals?priority=#{priority}&resolved=#{resolved}&user_info=#{user_info}&vod_id=#{vod_id}&limit=#{limit}&offset=#{offset}"

        begin
          response = client.get(path)
        rescue Faraday::Error::ResourceNotFound
          return []
        end
      end

    end
  end
end
