# frozen_string_literal: true

require "fileutils"
require "optparse"
require "rack"
require "socket"
require "stringio"

require_relative "toycol/const"
require_relative "toycol/helper"
require_relative "toycol/protocol"
require_relative "toycol/proxy"
require_relative "toycol/server"
require_relative "toycol/client"
require_relative "toycol/template_generator"
require_relative "toycol/command"
require_relative "toycol/version"

require_relative "rack/handler/toycol"

module Toycol
  class Error < StandardError; end

  class UnauthorizeError < Error; end

  class UndefinementError < Error; end

  class DuplicateProtocolError < Error; end

  class HTTPError < Error; end
end

Dir["#{FileUtils.pwd}/Protocolfile*"].sort.each { |f| load f }
