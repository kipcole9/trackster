module ActionView
  module TemplateHandlers
    class TextileTemplate < TemplateHandler
      include Compilable

      def compile(template)
        # Rails.logger.info "[Ruby Template] Compiling template '#{template}'"
        "self.output_buffer = template.source.textilize; self.output_buffer\n"
      end
    end
  end
end