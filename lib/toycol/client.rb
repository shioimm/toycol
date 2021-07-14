# frozen_string_literal: true

require "socket"

request_message = ARGV[0]

sock = TCPSocket.new("localhost", 9292)
sock.write(request_message)

while !sock.closed? && !sock.eof?
  message = sock.read_nonblock(1024)

  begin
    puts message
  rescue StandardError => e
    puts "#{e.class} #{e.message} - closing socket."
    e.backtrace.each { |l| puts "\t#{l}" }
  ensure
    sock.close
  end
end
