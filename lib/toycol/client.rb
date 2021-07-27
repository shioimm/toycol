# frozen_string_literal: true

module Toycol
  class Client
    extend Helper

    @port = 9292
    CHUNK_SIZE = 1024 * 16

    class << self
      attr_writer :port

      def execute!(request_message, &block)
        socket = TCPSocket.new("localhost", @port)
        socket.write(request_message)
        logger "Sent request message: #{request_message}\n---"

        response_message = []
        response_message << socket.readpartial(CHUNK_SIZE) until socket.eof?
        response_message = response_message.join

        block ||= default_proc
        block.call(response_message)
      ensure
        socket.close
      end

      private

      def default_proc
        proc do |message|
          logger "Received response message:\n\n"
          puts message
        end
      end
    end
  end
end
