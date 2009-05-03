module TranslationHelper
  def brackets_with_translation(*args) 
    args = [underscore.tr(' ', '_').to_sym] if args.empty? 
    return brackets_without_translation(*args) unless args.first.is_a? Symbol
    I18n.translate(args.first, :default => self)
  end
   
  def self.included(base) 
    base.class_eval do 
      alias :brackets :[] 
      alias_method_chain :brackets, :translation 
      alias :[] :brackets 
    end 
  end
end

