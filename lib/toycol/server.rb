# frozen_string_literal: true

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
        PATH_INFO         => "",
        QUERY_STRING      => "",
        REQUEST_METHOD    => "",
        SERVER_NAME       => "toycol_server",
        SERVER_PORT       => @port.to_s,
        CONTENT_LENGTH    => "0",
        RACK_VERSION      => Rack::VERSION,
        RACK_INPUT        => stringio(""),
        RACK_ERRORS       => $stderr,
        RACK_MULTITHREAD  => false,
        RACK_MULTIPROCESS => false,
        RACK_RUN_ONCE     => false,
        RACK_URL_SCHEME   => "http"
      }
    end

    def response_message
      "#{response_status_code}#{response_headers}\r\n#{response_body}"
    end

    def response_status_code
      "HTTP/1.1 #{@returned_status} #{DEFAULT_HTTP_STATUS_CODES[@returned_status.to_i] || "CUSTOM"}\r\n"
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

      @env[REQUEST_METHOD] = request_method
      @env[PATH_INFO]      = request_path
      @env[QUERY_STRING]   = query_string || ""
      @env[CONTENT_LENGTH]

      request_headers.each do |request_header|
        k, v = request_header.split(":").map(&:strip)
        @env[k.tr("-", "_").upcase.to_s] = v
      end

      @env[RACK_INPUT] = stringio(request_body)
    end
  end
end
