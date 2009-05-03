module ActionView
  module TemplateHandlers
    class RubyTemplate < TemplateHandler
      include Compilable

      def compile(template)
        "self.output_buffer = '';\n #{template.source}\n; self.output_buffer\n"
      end

    end
  end
end