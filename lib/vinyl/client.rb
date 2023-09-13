require 'faraday'
require 'faraday_middleware'

require 'vinyl/api/v1/amrs'
require 'vinyl/api/v1/appeals'
require 'vinyl/api/v1/user_video_privacy_properties'
require 'vinyl/api/v1/user_vod_properties'
require 'vinyl/api/v1/vods'
require 'vinyl/api/v1/thumbnails'

module Vinyl

  OPEN_TIMEOUT = 0.25
  READ_TIMEOUT = 0.25

  TOTAL_TIMEOUT = OPEN_TIMEOUT + READ_TIMEOUT
  # Client creates connections for http requests and returns the body of the
  # response
  class Client
    attr_accessor :version, :endpoint, :source
    attr_accessor :conn
    attr_accessor :amrs
    attr_accessor :appeals
    attr_accessor :user_video_privacy_properties
    attr_accessor :user_vod_properties
    attr_accessor :vods
    attr_accessor :thumbnails

    def initialize
      yield self if block_given?

      self.source = "code.justin.tv/#{source}" unless source.nil?
      setup_version

      self.conn = Faraday.new(url: endpoint) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response :json
        faraday.use Faraday::Response::RaiseError
        faraday.options[:open_timeout] = OPEN_TIMEOUT
        faraday.options[:timeout] = TOTAL_TIMEOUT
      end

      self.conn
    end

    def setup_version
      self.version = 1 if version.nil?

      case version
      when 1
        self.amrs = Vinyl::API::AmrV1.new(self)
        self.appeals = Vinyl::API::AppealV1.new(self)
        self.user_video_privacy_properties = Vinyl::API::UserVideoPrivacyPropertiesV1.new(self)
        self.user_vod_properties = Vinyl::API::UserVodPropertiesV1.new(self)
        self.vods = Vinyl::API::VodV1.new(self)
        self.thumbnails = Vinyl::API::ThumbnailsV1.new(self)
      end
    end

    def get(path, options = {})
      response = conn.get do |req|
        req.url path
        req.options = req.options.merge(options)
        req.headers['Twitch-Repository'] = source if source
      end
      response.body
    end

    def put(path, data, options = {})
      response = conn.put do |req|
        req.url path
        req.options = req.options.merge(options)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Twitch-Repository'] = source if source
        req.body = data.to_json
      end
      response.body
    end

    def post(path, data, options = {})
      response = conn.post do |req|
        req.url path
        req.options = req.options.merge(options)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Twitch-Repository'] = source if source
        req.body = data.to_json
      end
      response.body
    end

    def patch(path, data, options = {})
      response = conn.patch do |req|
        req.url path
        req.options = req.options.merge(options)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Twitch-Repository'] = source if source
        req.body = data.to_json
      end
      response.body
    end

    def delete(path, options = {})
      response = conn.delete do |req|
        req.url path
        req.options = req.options.merge(options)
        req.headers['Twitch-Repository'] = source if source
      end
      response.body
    end
  end
end
