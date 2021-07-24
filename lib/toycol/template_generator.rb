# frozen_string_literal: true

require "fileutils"

module Toycol
  class TemplateGenerator
    class << self
      def generate!(type:, name:)
        raise StandardError, "This type of template can't be generated" unless valid? type

        case type.to_s
        when "app"      then new(name).generate_app_template!
        when "protocol" then new(name).generate_protocol_template!
        when "all"
          generator = new(name)
          generator.generate_app_template!
          generator.generate_protocol_template!
        end
      end

      private

      def valid?(type)
        %w[all app protocol].include? type
      end
    end

    def initialize(name)
      @name = name
    end

    def generate_app_template!
      filename = "config_#{@name}.ru"
      File.open(filename, "w") { |f| f.print app_template_text }
      puts "Generate #{filename} in #{FileUtils.pwd}"
    end

    def generate_protocol_template!
      filename = "Protocolfile.#{@name}"

      File.open(filename, "w") do |f|
        text = protocol_template_text
        text.sub!(":PROTOCOL_NAME", ":#{@name}")
        f.print text
      end

      puts "Generate #{filename} in #{FileUtils.pwd}"
    end

    private

    def app_template_text
      File.open("lib/toycol/templates/application.txt", "r", &:read)
    end

    def protocol_template_text
      File.open("lib/toycol/templates/protocol.txt", "r", &:read)
    end
  end
end
