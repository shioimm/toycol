# frozen_string_literal: true

require "socket"

module Toycol
  class Client
    @port = 9292

    class << self
      attr_writer :port

      def execute!(request_message)
        socket = TCPSocket.new("localhost", @port)
        socket.write(request_message)
        puts "[Toycol] Sent request message: #{request_message}\n---"

        while !socket.closed? && !socket.eof?
          response_message = socket.read_nonblock(1024)
          puts "[Toycol] Received response message:\n\n"

          begin
            puts response_message
          rescue StandardError => e
            puts "#{e.class} #{e.message} - closing socket."
            e.backtrace.each { |l| puts "\t#{l}" }
          ensure
            socket.close
          end
        end
      end
    end
  end
end
