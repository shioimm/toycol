# frozen_string_literal: true

module Toycol
  # This class is for protocol definition and parsing request messages
  class Protocol
    @definements          = {}
    @protocol_name        = nil
    @http_status_codes    = Toycol::DEFAULT_HTTP_STATUS_CODES.dup
    @http_request_methods = Toycol::DEFAULT_HTTP_REQUEST_METHODS.dup
    @custom_status_codes  = nil
    @additional_request_methods = nil

    class << self
      def define(protocol_name = nil, &block)
        @definements[protocol_name] = block
      end

      def use(protocol_name)
        @protocol_name = protocol_name
      end

      def run!(message)
        @request_message = message.chomp

        return unless (block = @definements[@protocol_name])

        instance_exec(@request_message, &block)
      end

      if RUBY_VERSION >= "2.7"
        def custom_status_codes(**custom_status_codes)
          @custom_status_codes = custom_status_codes
        end
      else
        def custom_status_codes(custom_status_codes)
          @custom_status_codes = custom_status_codes
        end
      end

      def additional_request_methods(*additional_request_methods)
        @additional_request_methods = additional_request_methods
      end

      def request
        @request ||= Class.new do
          def self.path(&block)
            @path = block
          end

          def self.query(&block)
            @query = block
          end

          def self.http_method(&block)
            @http_method = block
          end

          def self.input(&block)
            @input = block
          end
        end
      end

      private

      attr_reader :request_message
    end
  end
end
