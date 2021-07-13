# frozen_string_literal: true

require_relative "toycol/const"
require_relative "toycol/protocol"
require_relative "toycol/version"

module Toycol
  class Error < StandardError; end

  class UnauthorizedRequestError < Error; end
end
