# frozen_string_literal: true

module Toycol
  class TemplateGenerator
    class << self
      def generate!(type:, name:)
        raise Toycol::Error, "Unknown Type: This type of template can't be generated" unless valid? type

        if type == "all"
          new(name, "protocol").generate!
          new(name, "app").generate!
        else
          new(name, type).generate!
        end
      end

      private

      def valid?(type)
        %w[all app protocol].include? type
      end
    end

    def initialize(name, type)
      @name = name
      @type = type
    end

    def generate!
      raise Toycol::Error, "#{filename} already exists" unless Dir.glob(filename).empty?

      File.open(filename, "w") { |f| f.print template_text_for_new }
      puts "Generate #{filename} in #{FileUtils.pwd}"
    end

    private

    def filename
      @filename ||= case @type
                    when "protocol" then "Protocolfile#{@name ? ".#{@name}" : nil}"
                    when "app"      then "config#{@name ? "_#{@name}" : nil}.ru"
                    end
    end

    def template_text_for_new
      if @name
        template_text.sub(":PROTOCOL_NAME", ":#{@name}")
      else
        template_text.sub("\(:PROTOCOL_NAME\)", "")
      end
    end

    def template_text
      case @type
      when "protocol" then File.open("#{__dir__}/templates/protocol.txt",    "r", &:read)
      when "app"      then File.open("#{__dir__}/templates/application.txt", "r", &:read)
      end
    end
  end
end
