module ActionView
  module TemplateHandlers
    class RubyTemplate < TemplateHandler
      include Compilable

      def compile(template)
        # Rails.logger.info "[Ruby Template] Compiling template '#{template}'"
        "self.output_buffer = '';\n #{template.source}\n; self.output_buffer.html_safe\n"
      end
    end
  end
end