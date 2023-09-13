require 'hystrix'


module Vinyl

  def self.default_user_video_privacy_properties(user_id)
    {
      'properties' => {
        'user_id' => user_id,
        'privacy_options_enabled' => false,
        'private_video' => false,
        'hide_archives' => false,
        'created_at' => Time.now,
        'updated_at' => Time.now
      }
    }
  end

  def self.default_user_vod_properties(user_id)
    {
      'properties' => {
        'user_id' => user_id,
        'save_vods_forever' => false,
        'vod_storage_days' => 14,
        'autosave_archives' => true,
        'can_upload_vod' => false,
        'youtube_exporting_disabled' => false,
        'created_at' => Time.now,
        'updated_at' => Time.now
      }
    }
  end

  class VinylCmd < Hystrix::Command

    class << self
      def inherited(subclass)
        super
        subclass.instance_eval do
          self.timeout_in_milliseconds TOTAL_TIMEOUT * 1000
          self.circuit_breaker(min_requests: 5)
        end
      end
    end

    attr_accessor :client

    def initialize(client)
      self.client = client
      super()
    end
  end

  class FindVodsForUser < VinylCmd
    attr_accessor :user_id, :broadcast_type, :language, :status, :sort, :limit, :offset, :appeals_and_amrs, :notification_settings, :filters

    def initialize(client, user_id, broadcast_type, language, status, sort, limit, offset, appeals_and_amrs, notification_settings, filters={})
      super client

      filters = {
        include_deleted: false,
        include_private: true,
        include_processing: true
      }.merge(filters)

      self.user_id = user_id
      self.broadcast_type = broadcast_type
      self.language = language
      self.status = status
      self.sort = sort
      self.limit = limit
      self.offset = offset
      self.appeals_and_amrs = appeals_and_amrs
      self.notification_settings = notification_settings
      self.filters = filters
    end

    def run
      self.client.vods.find_vods_for_user(
        user_id: self.user_id,
        broadcast_type: self.broadcast_type,
        language: self.language,
        status: self.status,
        sort: sort,
        limit: self.limit,
        offset: self.offset,
        appeals_and_amrs: self.appeals_and_amrs,
        notification_settings: self.notification_settings,
        filters: filters
      )
    end

    def fallback(error)
      nil
    end
  end

  class GetVodAppealsCmd < VinylCmd
    attr_accessor :priority, :resolved, :user_info, :vod_id, :limit, :offset

    def initialize(client, priority, resolved, user_info, vod_id, limit, offset)
      super client

      self.priority = priority
      self.resolved = resolved
      self.user_info = user_info
      self.vod_id = vod_id
      self.limit = limit
      self.offset = offset
    end

    def run
      self.client.appeals.get_vod_appeals(
        priority: self.priority,
        resolved: self.resolved,
        user_info: self.user_info,
        vod_id: self.vod_id,
        limit: self.limit,
        offset: self.offset
      )
    end

    def fallback(error)
      nil
    end
  end

  class GetVodsByStatusCmd < VinylCmd
    attr_accessor :status, :broadcast_type, :start_time, :end_time

    def initialize(client, status, broadcast_type, start_time, end_time)
      super client

      self.status = status
      self.broadcast_type = broadcast_type
      self.start_time = start_time
      self.end_time = end_time
    end

    def run
      self.client.vods.get_by_status(status: status, broadcast_type: broadcast_type, start_time: start_time, end_time: end_time)
    end

    def fallback(error)
      nil
    end
  end

  class GetVodsByIDs < VinylCmd
    attr_accessor :vod_ids, :appeals_and_amrs, :notification_settings, :filters

    def initialize(client, vod_ids, appeals_and_amrs, notification_settings, filters={})
      super client

      filters = {
        include_deleted: false,
        include_private: true,
        include_processing: true
      }.merge(filters)

      self.vod_ids = vod_ids
      self.appeals_and_amrs = appeals_and_amrs
      self.notification_settings = notification_settings
      self.filters = filters
    end

    def run
      self.client.vods.get_by_ids(
        vod_ids: vod_ids,
        appeals_and_amrs: appeals_and_amrs,
        notification_settings: notification_settings,
        filters: filters
      )
    end

    def fallback(error)
      {"vods" => []}
    end
  end

  class DeleteVods < VinylCmd
    attr_accessor :vod_ids, :destroy

    def initialize(client, vod_ids, destroy)
      super client
      self.vod_ids = vod_ids
      self.destroy = destroy
    end

    def run
      self.client.vods.delete(vod_ids: vod_ids, destroy: destroy)
    end

    def fallback(error)
      nil
    end
  end

  class DestroyAllVodsForUser < VinylCmd
    attr_accessor :user_id

    def initialize(client, user_id)
      super client
      self.user_id = user_id
    end

    def run
      self.client.vods.destroy_all_for_user(user_id: user_id)
    end

    def fallback(error)
      nil
    end
  end

  class CreateAMR < VinylCmd
    attr_accessor :vod_id, :amr_fields

    def initialize(client, vod_id, amr_fields)
      super client

      self.vod_id = vod_id
      self.amr_fields = amr_fields
    end

    def run
      self.client.amrs.create_amr(vod_id: self.vod_id, amr_fields: self.amr_fields)
    end

    def fallback(error)
      nil
    end
  end

  class GetAMRsForVod < VinylCmd
    attr_accessor :vod_id

    def initialize(client, vod_id)
      super client
      self.vod_id = vod_id
    end

    def run
      self.client.amrs.get_for_vod(vod_id: vod_id)
    end

    def fallback(error)
      nil
    end
  end

  class CreateHighlight < VinylCmd
    attr_accessor :highlight_fields

    def initialize(client, highlight_fields)
      super client

      self.highlight_fields = highlight_fields
    end

    def run
      self.client.vods.create_highlight(highlight_fields: self.highlight_fields)
    end

    def fallback(error)
      nil
    end
  end

  class CreatePastBroadcast < VinylCmd
    attr_accessor :vod_fields

    def initialize(client, vod_fields)
      super client

      self.vod_fields = vod_fields
    end

    def run
      self.client.vods.create_past_broadcast(vod_fields: self.vod_fields)
    end

    def fallback(error)
      nil
    end
  end



  class UpdateVod < VinylCmd
    attr_accessor :vod_id, :options

    def initialize(client, vod_id, options)
      super client

      self.vod_id = vod_id
      self.options = options
    end

    def run
      self.client.vods.update(
        vod_id: self.vod_id,
        options: self.options
      )
    end

    def fallback(error)
      nil
    end
  end

  class UpdateAMR < VinylCmd
    attr_accessor :amr_id, :amr_fields

    def initialize(client, amr_id, amr_fields)
      super client

      self.amr_id = amr_id
      self.amr_fields = amr_fields
    end

    def run
      self.client.amrs.update_amr(amr_id: self.amr_id, amr_fields: self.amr_fields)
    end

    def fallback(error)
      nil
    end
  end

  class CreateAppeals < VinylCmd
    attr_accessor :vod_id, :vod_appeal_params, :track_appeals

    def initialize(client, vod_id, vod_appeal_params, track_appeals)
      super client

      self.vod_id = vod_id
      self.vod_appeal_params = vod_appeal_params
      self.track_appeals = track_appeals
    end

    def run
      self.client.appeals.create_appeals(
        vod_id: self.vod_id,
        vod_appeal_params: self.vod_appeal_params,
        track_appeals: self.track_appeals
      )
    end

    def fallback(error)
      nil
    end
  end

  class Top < VinylCmd
    attr_accessor :broadcast_type, :game, :period, :language, :sort, :limit, :offset

    TIMEOUT = 5 * 1000
    timeout_in_milliseconds TIMEOUT

    def initialize(client, broadcast_type, game, period, language, sort, limit, offset)
      super client

      self.broadcast_type = broadcast_type
      self.game = game
      self.period = period
      self.language = language
      self.sort = sort
      self.limit = limit
      self.offset = offset
    end

    def run
      self.client.vods.top(
        broadcast_type: self.broadcast_type,
        game: self.game,
        period: self.period,
        sort: self.sort,
        language: self.language,
        limit: self.limit,
        offset: self.offset,
        timeout: TIMEOUT
      )
    end

    def fallback(error)
      nil
    end
  end

  class Followed < VinylCmd
    attr_accessor :followed_ids, :broadcast_type, :language, :status, :sort, :limit, :offset

    TIMEOUT = 5 * 1000
    timeout_in_milliseconds TIMEOUT

    def initialize(client, followed_ids, broadcast_type, language, status, sort, limit, offset)
      super client

      self.followed_ids = followed_ids
      self.broadcast_type = broadcast_type
      self.language = language
      self.status = status
      self.sort = sort
      self.limit = limit
      self.offset = offset
    end

    def run
      self.client.vods.followed(
        followed_ids: self.followed_ids,
        broadcast_type: self.broadcast_type,
        language: self.language,
        status: self.status,
        sort: self.sort,
        limit: self.limit,
        offset: self.offset,
        timeout: TIMEOUT
      )
    end

    def fallback(error)
      nil
    end
  end

  class Related < VinylCmd
    attr_accessor :user_id, :vod_id

    def initialize(client, user_id, vod_id)
      super client

      self.user_id = user_id
      self.vod_id = vod_id
    end

    def run
      self.client.vods.related(
        user_id: self.user_id,
        vod_id: self.vod_id
      )
    end

    def fallback(error)
      nil
    end
  end

  class GetVodsByQuery < VinylCmd
    attr_accessor :broadcast_ids

    def initialize(client, broadcast_ids)
      super(client)

      self.broadcast_ids = broadcast_ids
    end

    def run
      self.client.vods.get_vods_by_query(
        broadcast_ids: self.broadcast_ids
      )
    end

    def fallback(error)
      nil
    end
  end

  class GetUserVideoPrivacyProperties < VinylCmd
    attr_accessor :user_id

    def initialize(client, user_id)
      super client

      self.user_id = user_id
    end

    def run
      self.client.user_video_privacy_properties.get(
        user_id: self.user_id
      )
    end

    def fallback(error)
      ::Vinyl.default_user_video_privacy_properties(self.user_id)
    end
  end

  class SetUserVideoPrivacyProperties < VinylCmd
    attr_accessor :user_id, :properties

    def initialize(client, user_id, properties)
      super client

      self.user_id = user_id
      self.properties = properties
    end

    def run
      self.client.user_video_privacy_properties.set(
        user_id: self.user_id,
        properties: self.properties
      )
    end

    def fallback(error)
      ::Vinyl.default_user_video_privacy_properties(self.user_id)
    end
  end

  class GetUserVodProperties < VinylCmd
    attr_accessor :user_id

    def initialize(client, user_id)
      super client

      self.user_id = user_id
    end

    def run
      self.client.user_vod_properties.get(
        user_id: self.user_id
      )
    end

    def fallback(error)
      ::Vinyl.default_user_vod_properties(self.user_id)
    end
  end

  class SetUserVodProperties < VinylCmd
    attr_accessor :user_id, :properties

    def initialize(client, user_id, properties)
      super client

      self.user_id = user_id
      self.properties = properties
    end

    def run
      self.client.user_vod_properties.set(
        user_id: self.user_id,
        properties: self.properties
      )
    end

    def fallback(error)
      ::Vinyl.default_user_vod_properties(self.user_id)
    end
  end

  class CreateThumbnails < VinylCmd
    attr_accessor :vod_id, :thumbnails

    def initialize(client, vod_id, thumbnails)
      super(client)

      self.vod_id = vod_id
      self.thumbnails = thumbnails
    end

    def run
      self.client.thumbnails.create(
        vod_id: self.vod_id,
        thumbnails: self.thumbnails
      )
    end

    def fallback(error)
      []
    end
  end

  class DeleteThumbnail < VinylCmd
    attr_accessor :vod_id, :path

    def initialize(client, vod_id, path)
      super(client)

      self.vod_id = vod_id
      self.path = path
    end

    def run
      self.client.thumbnails.delete(
        vod_id: self.vod_id,
        path: self.path
      )
    end

    def fallback(error)
      {"error" => "Unable to delete thumbnail; vod_id: #{vod_id}, path: #{path}"}
    end
  end
end
