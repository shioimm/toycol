module Toycol
  class TemplateGenerator
    class << self
      def generate!(type:, name:)
        raise StandardError, "This type of template can't be generated" unless %i[app protocol].include? type

        case type
        when :app
          File.open("config_#{name}.ru", "w") { |f| f.print app_template_text }
        end
      end

      private

      def app_template_text
        File.open("lib/toycol/templates/application.txt", "r") { |f| f.read }
      end
    end
  end
end
