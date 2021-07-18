# frozen_string_literal: true

require "optparse"
require_relative "./client"

module Toycol
  class Command
    class Options
      class << self
        def parse!(argv)
          options            = {}
          option_parser      = create_option_parser
          sub_command_parser = create_sub_command_parser

          begin
            option_parser.order!(argv)
            options[:command]         = argv.shift
            options[:request_message] = argv.shift if %w[client c].include? options[:command]

            sub_command_parser[options[:command]].parse!(argv)
          rescue OptionParser::MissingArgument, OptionParser::InvalidOption, ArgumentError => e
            abort e.message
          end

          options
        end

        def create_option_parser
          OptionParser.new do |opt|
            opt.banner = "Usage: toycol [options]"

            opt.on("-v", "--version", "Show Toycol version") do
              opt.version = Toycol::VERSION
              puts opt.ver
              exit
            end
          end
        end

        def create_sub_command_parser
          sub_command_parser = Hash.new { |_k, v| raise ArgumentError, "'#{v}' is not sub command" }
          sub_command_parser["client"] = client_option_parser
          sub_command_parser["c"]      = client_option_parser
          sub_command_parser
        end

        private

        def client_option_parser
          OptionParser.new do |opt|
            opt.on("-p=PORT_NUMBER", "--port=PORT_NUMBER", "Set port number") do |n|
              ::Toycol::Client.port = n
            end
          end
        end
      end
    end

    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv
    end

    def execute
      options = Options.parse!(@argv)
      command = options.delete(:command)

      case command
      when "client", "c" then ::Toycol::Client.execute!(options[:request_message])
      end
    end
  end
end
