# frozen_string_literal: true

require "optparse"
require_relative "./client"

module Toycol
  class Command
    class Options
      class << self
        def parse!(argv)
          options       = {}
          option_parser = create_option_parser
          sub_command_option_parser = create_sub_command_option_parser

          begin
            option_parser.order!(argv)
            options[:command]         = argv.shift
            options[:request_message] = argv.shift if %w[client c].include?(options[:command]) && argv.first != "-h"
            sub_command_option_parser[options[:command]].parse!(argv)
          rescue OptionParser::MissingArgument, OptionParser::InvalidOption, ArgumentError => e
            abort e.message
          end

          options
        end

        def create_option_parser
          OptionParser.new do |opt|
            opt.banner = "Usage: #{opt.program_name} [-h|--help] [-v|--version] COMMAND [arg...]"

            opt.on_head("-v", "--version", "Show Toycol version") do
              opt.version = Toycol::VERSION
              puts opt.ver
              exit
            end
            opt.on_head("-h", "--help", "Show this message") { help_command(opt) }

            opt.separator ""
            opt.separator "Sub commands:"
            sub_command_summaries.each do |command|
              opt.separator [opt.summary_indent, command[:name].ljust(31), command[:summary]].join(" ")
            end
          end
        end

        def create_sub_command_option_parser
          sub_command_parser = Hash.new { |_k, v| raise ArgumentError, "'#{v}' is not sub command" }
          sub_command_parser["client"] = client_option_parser
          sub_command_parser["c"]      = client_option_parser
          sub_command_parser["server"] = server_option_parser
          sub_command_parser["s"]      = server_option_parser
          sub_command_parser
        end

        private

        def sub_command_summaries
          [
            { name: "client REQUEST_MESSAGE -p PORT",  summary: "Send request message to server"    },
            { name: "server -u SERVER_NAME",           summary: "Start proxy and background server" }
          ]
        end

        def client_option_parser
          OptionParser.new do |opt|
            opt.on("-p PORT_NUMBER", "--port PORT_NUMBER", "listen on PORT (default: 9292)") do |port|
              ::Toycol::Client.port = port
            end

            opt.on_head("-h", "--help", "Show this message") { help_command(opt) }
          end
        end

        def server_option_parser
          OptionParser.new do |opt|
            opt.on("-o HOST", "--host HOST", "bind to HOST (default: localhost)") do |host|
              ::Rack::Handler::Toycol.host = host
            end

            opt.on("-p PORT_NUMBER", "--port PORT_NUMBER", "listen on PORT (default: 9292)") do |port|
              ::Rack::Handler::Toycol.port = port
            end

            opt.on("-u SERVER_NAME", "--use SERVER_NAME", "switch using SERVER(puma/build_in)") do |server_name|
              ::Rack::Handler::Toycol.preferred_background_server = server_name
            end

            opt.on_head("-h", "--help", "Show this message") { help_command(opt) }
          end
        end

        def help_command(parser)
          puts parser.help
          exit
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
      when "client", "c"
        ::Toycol::Client.execute!(options[:request_message])
      when "server", "s"
        ARGV.push("-q", "-s", "toycol")
        Rack::Server.start
      end
    end
  end
end
