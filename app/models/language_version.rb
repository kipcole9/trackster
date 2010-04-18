class LanguageVersion < ActiveRecord::Base
  belongs_to        :variant
  
  # We don't aske the user to set the language we use the rules from HTTP and HTML
  # to decide.  The reference document is http://www.w3.org/TR/NOTE-html-lan
  #
  # Hierarchy of determination:
  # => <BODY lang='xx'>
  # => <META HTTP-EQUIV="Content-Language" Content="xx"> 
  # => HTTP Content-Language header if provided and if source is from a URL
  # => The default language of the account
  #
  # Such a hierarchy should provide the appropriate correctness in nearly
  # all cases without a typical user having to get involved in any
  # complexity.
  def language=(lang)
    super
  end
  
  
  
end
