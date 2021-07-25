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
      # For protocol definition
      def define(protocol_name = nil, &block)
        @definements[protocol_name] = block
      end

      # For application which use the protocol
      def use(protocol_name = nil)
        @protocol_name = protocol_name
      end

      # For server which use the protocol
      def run!(message)
        @request_message = message.chomp

        return unless (block = @definements[@protocol_name])

        instance_exec(@request_message, &block)
      end

      # For protocol definition: Define custom status codes
      if RUBY_VERSION >= "2.7"
        def custom_status_codes(**custom_status_codes)
          @custom_status_codes = custom_status_codes
        end
      else
        def custom_status_codes(custom_status_codes)
          @custom_status_codes = custom_status_codes
        end
      end

      # For protocol definition: Define adding request methods
      def additional_request_methods(*additional_request_methods)
        @additional_request_methods = additional_request_methods
      end

      # For protocol definition: Define how to parse the request message
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

      # For server: Get the request path
      def request_path
        request_path = request.instance_variable_get("@path").call(request_message)

        raise Toycol::UnauthorizeError, "This request path is too long" if request_path.size >= 2048

        if request_path.scan(%r{[/\w\d\-_]}).size < request_path.size
          raise Toycol::UnauthorizeError,
                "This request path contains unauthorized character"
        end

        request_path
      end

      # For server: Get the request method
      def request_method
        @http_request_methods.concat @additional_request_methods if @additional_request_methods
        request_method = request.instance_variable_get("@http_method").call(request_message)

        unless @http_request_methods.include? request_method
          raise Toycol::UndefinementError, "This request method is undefined"
        end

        request_method
      end

      # For server: Get the query string
      def query
        return unless (parse_query_block = request.instance_variable_get("@query"))

        parse_query_block.call(request_message)
      end

      # For server: Get the input body
      def input
        return unless (parsed_input_block = request.instance_variable_get("@input"))

        parsed_input_block.call(request_message)
      end

      # For server: Get the message of status code
      def status_message(status)
        @http_status_codes.merge!(@custom_status_codes) if @custom_status_codes

        unless (message = @http_status_codes[status])
          raise Toycol::HTTPError, "Application returns unknown status code"
        end

        message
      end

      private

      attr_reader :request_message
    end
  end
end
