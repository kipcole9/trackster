module Caerus
  module FormBuilderHelper
    def caerus_form_for(name, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options = options.merge!(:builder => Caerus::FormBuilder)   
      args = args << options 
      form_for(name, *args, &block) 
    end
  
    def caerus_fields_for(name, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options = options.merge!(:builder => Caerus::FormBuilder)   
      args = args << options 
      fields_for(name, *args, &block)
    end
  end
end
