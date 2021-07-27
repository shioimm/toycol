# frozen_string_literal: true

module Toycol
  class Proxy
    include Helper

    def initialize(host, port)
      @host           = host
      @port           = port
      @request_method = nil
      @path           = nil
      @query          = nil
      @input          = nil
      @protocol       = Protocol
      @proxy          = TCPServer.new(@host, @port)
    end

    CHUNK_SIZE = 1024 * 16

    def start
      logger <<~MESSAGE
        Start proxy server on #{@protocol.protocol_name} protocol, listening on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      loop do
        trap(:INT) { shutdown }

        @client = @proxy.accept

        while !@client.closed? && !@client.eof?
          begin
            request = @client.readpartial(CHUNK_SIZE)
            logger "Received message: #{request.inspect.chomp}"

            safe_execution! { @protocol.run!(request) }
            assign_parsed_attributes!

            http_request_message = build_http_request_message
            logger "Message has been translated to HTTP request message: #{http_request_message.inspect}"
            transfer_to_server(http_request_message)
          rescue StandardError => e
            puts "#{e.class} #{e.message} - closing socket."
            e.backtrace.each { |l| puts "\t#{l}" }
            @proxy.close
            @client.close
          end
        end
        @client.close
      end
    end

    private

    def assign_parsed_attributes!
      @request_method = @protocol.request_method
      @path  = @protocol.request_path
      @query = @protocol.query
      @input = @protocol.input
    end

    def build_http_request_message
      request_message = "#{request_line}#{request_header}\r\n"
      request_message += @input if @input
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
      UNIXSocket.open(UNIX_SOCKET_PATH) do |server|
        server.write request_message
        server.close_write
        logger "Successed to Send HTTP request message to server"

        response_message = []
        response_message << server.readpartial(CHUNK_SIZE) until server.eof?
        response_message = response_message.join
        logger "Received response message from server: #{response_message.lines.first}"

        response_line  = response_message.lines.first
        status_number  = response_line[9..11]
        status_message = response_line[12..].strip

        if (custom_message = @protocol.status_message(status_number.to_i)) != status_message
          response_message = response_message.sub(status_message, custom_message)
          logger "Status message has been translated to custom status message: #{custom_message}"
        end

        @client.write response_message
        @client.close_write
        logger "Finished to response to client"
        server.close
      end
    end

    def shutdown
      logger "Caught SIGINT -> Stop to server"
      exit
    end
  end
end
