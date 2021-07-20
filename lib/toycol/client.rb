# frozen_string_literal: true

require "socket"

module Toycol
  class Client
    @port = 9292
    CHUNK_SIZE = 1024 * 16

    class << self
      attr_writer :port

      def execute!(request_message)
        socket = TCPSocket.new("localhost", @port)
        socket.write(request_message)
        puts "[Toycol] Sent request message: #{request_message}\n---"

        response_message = []
        response_message << socket.readpartial(CHUNK_SIZE) until socket.eof?
        response_message = response_message.join

        puts "[Toycol] Received response message:\n\n"
        puts response_message
        socket.close
      end
    end
  end
end
