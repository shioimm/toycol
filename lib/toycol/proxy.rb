# frozen_string_literal: true

require "socket"

module Toycol
  class Proxy
    def initialize(host, port)
      @host           = host
      @port           = port
      @request_method = nil
      @path           = nil
      @query          = nil
      @input          = nil
      @protocol       = ::Toycol::Protocol
      @proxy          = TCPServer.new(@host, @port)
    end

    def start
      puts <<~MESSAGE
        Toycol is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      loop do
        trap(:INT) { shutdown }

        @client = @proxy.accept

        while !@client.closed? && !@client.eof?
          request = @client.readpartial(1024)

          begin
            puts "[Toycol] Received message:\n#{request.inspect.chomp}"
            @protocol.run!(request)
            assign_parsed_attributes!

            http_request_message = build_http_request_message
            puts "[Toycol] Message has been translated to HTTP request message:\n#{http_request_message.inspect}"
            transfer_to_server(http_request_message)
          rescue StandardError => e
            puts "#{e.class} #{e.message} - closing socket."
            e.backtrace.each { |l| puts "\t#{l}" }
            @proxy.close
          ensure
            @client.close
          end
        end
      end
    end

    private

    NEWLINE = "\r\n"
    private_constant :NEWLINE

    def assign_parsed_attributes!
      @request_method = @protocol.request_method
      @path  = @protocol.request_path
      @query = @protocol.query
      @input = @protocol.input
    end

    def build_http_request_message
      request_message = request_line + request_header + NEWLINE
      request_message.concat(@input + NEWLINE) if @input
      request_message
    end

    def request_line
      "#{@request_method} #{request_path} HTTP/1.1\r\n"
    end

    def request_path
      return @path unless @request_method == "GET"

      "#{@path}#{"?#{@query}" if @query && !@query.empty?}"
    end

    def request_header
      "Content-Length: #{@input&.bytesize || 0}\r\n"
    end

    def transfer_to_server(request_message)
      UNIXSocket.open(Toycol::UNIX_SOCKET_PATH) do |server|
        server.write request_message
        puts "[Toycol] Successed to Send HTTP request message to server"

        while !server.closed? && !server.eof?
          message = server.read_nonblock(1024)
          puts "[Toycol] Received response message from server:\n#{message.lines.first.inspect}"

          begin
            @client.write message
          rescue StandardError => e
            puts "[Toycol] #{e.class} #{e.message} - closing socket"
            e.backtrace.each { |l| puts "\t#{l}" }
          ensure
            server.close
          end
        end
      end
    end

    def shutdown
      puts "[Toycol] Catched SIGINT -> Stop to server"
      exit
    end
  end
end
