require 'vinyl/client'
require 'vinyl/commands'

require 'logger'

# Vinyl module for the gem
module Vinyl
  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end

Vinyl.logger = Logger.new(STDOUT)
Vinyl.logger.level = Logger::WARN
