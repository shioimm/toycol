# frozen_string_literal: true

require_relative "toycol/const"
require_relative "toycol/helper"
require_relative "toycol/protocol"
require_relative "toycol/proxy"
require_relative "rack/handler/toycol"

Dir["#{FileUtils.pwd}/Protocolfile*"].sort.each { |f| load f }

require_relative "toycol/version"

module Toycol
  class Error < StandardError; end

  class UnauthorizedMethodError < Error; end

  class UnauthorizedRequestError < Error; end

  class UndefinedRequestMethodError < Error; end

  class UnknownStatusCodeError < Error; end
end
