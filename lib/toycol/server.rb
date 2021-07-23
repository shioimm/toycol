# frozen_string_literal: true

require "stringio"

module Toycol
  class Server
    BACKLOG    = 1024
    CHUNK_SIZE = 1024 * 16

    class << self
      def run(app, **options)
        new(app, **options).run
      end
    end

    def initialize(app, **options)
      @app  = app
      @path = options[:Path]
      @port = options[:Port]
      @env  = default_env
      @returned_status  = nil
      @returned_headers = nil
      @returned_body    = nil
    end

    def run
      verify_file_path!
      server = UNIXServer.new @path
      server.listen BACKLOG

      loop do
        trap(:INT) { exit }

        socket = server.accept

        request_message = []
        request_message << socket.readpartial(CHUNK_SIZE) until socket.eof?
        request_message = request_message.join
        assign_parsed_attributes!(request_message)

        @returned_status, @returned_headers, @returned_body = @app.call(@env)

        socket.puts response_message
        socket.close_write
        socket.close
      end
    end

    private

    def default_env
      {
        ::Toycol::PATH_INFO         => "",
        ::Toycol::QUERY_STRING      => "",
        ::Toycol::REQUEST_METHOD    => "",
        ::Toycol::SERVER_NAME       => "toycol_server",
        ::Toycol::SERVER_PORT       => @port.to_s,
        ::Toycol::CONTENT_LENGTH    => "0",
        ::Toycol::RACK_VERSION      => Rack::VERSION,
        ::Toycol::RACK_INPUT        => stringio(""),
        ::Toycol::RACK_ERRORS       => $stderr,
        ::Toycol::RACK_MULTITHREAD  => false,
        ::Toycol::RACK_MULTIPROCESS => false,
        ::Toycol::RACK_RUN_ONCE     => false,
        ::Toycol::RACK_URL_SCHEME   => "http"
      }
    end

    def response_message
      "#{response_status_code}#{response_headers}\r\n#{response_body}"
    end

    def response_status_code
      "HTTP/1.1 #{@returned_status} #{::Toycol::DEFAULT_HTTP_STATUS_CODES[@returned_status.to_i] || "CUSTOM"}\r\n"
    end

    def response_headers
      @returned_headers["Content-Length"] = response_body.size unless @returned_headers["Content-Length"]

      @returned_headers.map { |k, v| "#{k}: #{v}" }.join("\r\n") + "\r\n"
    end

    def response_body
      res = []
      @returned_body.each { |body| res << body }
      res.join
    end

    def stringio(body = "")
      StringIO.new(body).set_encoding("ASCII-8BIT")
    end

    def verify_file_path!
      return unless File.exist? @path

      begin
        bound_file = UNIXSocket.new @path
      rescue SystemCallError, IOError
        File.unlink @path
      else
        bound_file.close
        raise "[Toycol] Address already in use: #{@path}"
      end
    end

    def assign_parsed_attributes!(request_message)
      request_line, *request_headers, request_body = request_message.split("\r\n").reject(&:empty?)
      request_method, request_path, = request_line.split
      request_path, query_string    = request_path.split("?")

      @env[::Toycol::REQUEST_METHOD] = request_method
      @env[::Toycol::PATH_INFO]      = request_path
      @env[::Toycol::QUERY_STRING]   = query_string || ""
      @env[::Toycol::CONTENT_LENGTH]

      request_headers.each do |request_header|
        k, v = request_header.split(":").map(&:strip)
        @env["::Toycol::#{k.tr("-", "_").upcase}"] = v
      end

      @env[::Toycol::RACK_INPUT] = stringio(request_body)
    end
  end
end
