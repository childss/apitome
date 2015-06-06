require "kramdown"

require "apitome/version"
require "apitome/exceptions"
require "apitome/configuration"

require "apitome/engine"

module Apitome
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    yield configuration if block_given?
  end
end
