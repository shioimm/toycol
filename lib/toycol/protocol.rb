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

      def request_path
        request_path = request.instance_variable_get("@path").call(request_message)

        raise UnauthorizedRequestError, "This request path is too long" if request_path.size >= 2048

        if request_path.scan(%r{[/\w\d\-_]}).size < request_path.size
          raise UnauthorizedRequestError,
                "This request path contains unauthorized character"
        end

        request_path
      end

      def request_method
        @http_request_methods.concat @additional_request_methods if @additional_request_methods
        request_method = request.instance_variable_get("@http_method").call(request_message)

        unless @http_request_methods.include? request_method
          raise UndefinedRequestMethodError, "This request method is undefined"
        end

        request_method
      end

      def query
        return unless (parse_query_block = request.instance_variable_get("@query"))

        parse_query_block.call(request_message)
      end

      def input
        return unless (parsed_input_block = request.instance_variable_get("@input"))

        parsed_input_block.call(request_message)
      end

      def status_message(status)
        @http_status_codes.merge!(@custom_status_codes) if @custom_status_codes

        unless (message = @http_status_codes[status])
          raise UnknownStatusCodeError, "Application returns unknown status code"
        end

        message
      end

      private

      attr_reader :request_message
    end
  end
end
