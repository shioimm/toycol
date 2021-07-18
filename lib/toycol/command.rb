# frozen_string_literal: true

require "optparse"
require_relative "./client"

module Toycol
  class Command
    module Options
      def self.parse!(argv)
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: toycol [options]"

          opts.on("-c", "--client=REQUEST_MESSGAGE", "Sent request message to server") do |request_message|
            ::Toycol::Client.execute!(request_message)
          end

          opts.on("-v", "--version", "Show Toycol version") do
            opts.version = Toycol::VERSION
            puts opts.ver
            exit
          end
        end

        opt_parser.parse!(argv)
      end
    end

    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv
    end

    def execute
      Options.parse!(@argv)
    end
  end
end
