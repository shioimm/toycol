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
            opt.banner = "Usage: #{opt.program_name} [-h|--help] [-v|--version] <command> <args>"
            display_adding_summary(opt)

            opt.on_head("-h", "--help", "Show this message") do
              puts opt.help
              exit
            end

            opt.on_head("-v", "--version", "Show Toycol version") do
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
          sub_command_parser["server"] = server_option_parser
          sub_command_parser["s"]      = server_option_parser
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

        def server_option_parser
          OptionParser.new do |opt|
            opt.on("-u=SERVER_NAME", "--use=SERVER_NAME", "Switch background server") do |server_name|
              ::Rack::Handler::Toycol.preferred_background_server = server_name
            end
          end
        end

        def display_adding_summary(opt)
          opt.separator ""
          opt.separator "Client command options:"
          client_command_help_messages.each { |command| display_addimg_summary_line(opt, command) }

          opt.separator ""
          opt.separator "Server command options:"
          server_command_help_messages.each { |command| display_addimg_summary_line(opt, command) }
        end

        def display_addimg_summary_line(opt, command)
          opt.separator [opt.summary_indent, command[:name].ljust(31), command[:summary]].join(" ")
        end

        def client_command_help_messages
          [
            { name: "client -p=PORT_NUMBER", summary: "Send request to server" }
          ]
        end

        def server_command_help_messages
          [
            { name: "server --use=SERVER_NAME", summary: "Start proxy & background server" }
          ]
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
