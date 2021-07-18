# frozen_string_literal: true

require "optparse"

module Toycol
  class Command
    module Options
      def self.parse!(argv)
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: toycol [options]"

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
