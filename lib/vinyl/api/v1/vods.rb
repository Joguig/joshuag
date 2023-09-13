module Vinyl
  module API
    # VodV1 is the v1 of Vinyl's vod endpoints
    class VodV1
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def create_past_broadcast(vod_fields:)
        path = "/v1/vods/past_broadcast"

        body = Hash.new
        body["past_broadcast"] = vod_fields

        begin
          response = client.post(path, body)
        rescue Faraday::Error::ResourceNotFound
          return nil
        rescue Faraday::Error::ClientError => err
          # pass back Vinyl error through to rails.
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to create past broadcast"}
        end

        response
      end

      def create_highlight(highlight_fields:)
        path = "/v1/vods/highlight"

        body = Hash.new
        body["highlight"] = highlight_fields

        begin
          response = client.post(path, body)
        rescue Faraday::Error::ResourceNotFound
          return nil
        rescue Faraday::Error::ClientError => err
          # pass back Vinyl error through to rails.
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to create highlight"}
        end

        response
      end


      def delete(vod_ids:, destroy:)
        path = "/v1/vods?ids=#{vod_ids.join(',')}&destructive=#{destroy}"

        begin
          response = client.delete(path)
        rescue Faraday::Error::ClientError
          return nil
        end

        response
      end

      def destroy_all_for_user(user_id:)
        path = "/v1/users/#{user_id}/vods"

        begin
          response = client.delete(path)
        rescue Faraday::Error::ClientError => err
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to destroy all vods for user #{user_id}"}
        end

        response
      end

      def update(vod_id:, options:)
        path = "/v1/vods/#{vod_id}"

        begin
          response = client.put(path, options)
        rescue Faraday::Error::ResourceNotFound
          return nil
        rescue Faraday::Error::ClientError => err
          # pass back Vinyl error through to rails.
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to update vod #{vod_id}"}
        end

        response
      end

      def find_vods_for_user(user_id:, broadcast_type:, language:, status:, sort:, limit:, offset:, appeals_and_amrs:, notification_settings:, filters:)
        path = "/v1/vods/user/#{user_id}?broadcast_type=#{broadcast_type}&language=#{language}&status=#{status}&sort=#{sort}&limit=#{limit}&offset=#{offset}&appeals_and_amrs=#{appeals_and_amrs}&notification_settings=#{notification_settings}"
        path = append_vod_filters(path, filters)

        begin
          response = client.get(path)
        rescue Faraday::Error::ClientError => err
          # pass back Vinyl error through to rails.
          if err.response
            return JSON.parse(err.response[:body])
          end
          return {"error" => "Client error trying to find vods for user."}
        end

        response
      end

      def get_by_status(status:, broadcast_type: nil, start_time: nil, end_time: nil)
        path = "/v1/vods/status/#{status}?"
        params = []

        if !broadcast_type.nil? && !broadcast_type.empty?
          params << "broadcast_type=#{broadcast_type}"
        end
        if !start_time.nil?
          params << "start_time=#{start_time}"
        end
        if !end_time.nil?
          params << "end_time=#{end_time}"
        end

        begin
          client.get(path + params.join("&"))
        rescue Faraday::Error::ResourceNotFound
          return []
        end
      end

      def get_by_ids(vod_ids:, appeals_and_amrs:, notification_settings:, filters:)
        path = "/v1/vods?ids=#{vod_ids.join(',')}&appeals_and_amrs=#{appeals_and_amrs}&notification_settings=#{notification_settings}"
        path = append_vod_filters(path, filters)

        begin
          response = client.get(path)
        rescue Faraday::Error::ClientError
          return { "error" => "Client error while fetching vods by IDs" }
        end

        response
      end

      def top(broadcast_type:, game:, period:, language:, sort:, limit:, offset:, timeout:)
        path = "/v1/vods/top?broadcast_type=#{broadcast_type}&game=#{game}&period=#{period}&language=#{language}&sort=#{sort}&limit=#{limit}&offset=#{offset}"

        begin
          response = client.get(path, timeout: timeout)
        rescue Faraday::Error::ResourceNotFound
          return []
        end

        response
      end

      def followed(followed_ids:, broadcast_type:, language:, status:, sort:, limit:, offset:, timeout:)
        path = "/v1/vods/followed?broadcast_type=#{broadcast_type}&language=#{language}&status=#{status}&sort=#{sort}&limit=#{limit}&offset=#{offset}"

        begin
          response = client.post(path, followed_ids, timeout: timeout)
        rescue Faraday::Error::ResourceNotFound
          return []
        end

        response
      end

      def related(user_id:, vod_id: 0)
        path = "/v1/vods/related?user_id=#{user_id}&vod_id=#{vod_id}"

        begin
          response = client.get(path)
        rescue Faraday::Error::ResourceNotFound
          return []
        end

        response
      end

      def get_vods_by_query(broadcast_ids:[])
        path = "/v1/vods_by_query?broadcast_ids=#{broadcast_ids.join(',')}"

        begin
          response = client.get(path)
        rescue Faraday::Error::ResourceNotFound
          return []
        end

        response
      end

      private

      def append_vod_filters(path, filters)
        if filters.has_key?(:include_deleted)
          path += "&include_deleted=#{!!filters[:include_deleted]}"
        end
        if filters.has_key?(:include_private)
          path += "&include_private=#{!!filters[:include_private]}"
        end
        if filters.has_key?(:include_processing)
          path += "&include_processing=#{!!filters[:include_processing]}"
        end
        path
      end
    end
  end
end
