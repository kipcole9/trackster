I18n::Backend::Simple.send(:include, I18n::Backend::InterpolationCompiler)
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n::Backend::Simple.send(:include, I18n::Backend::Cldr)
I18n.fallbacks["en-US"] = :en
I18n.fallbacks["en-GB"] = :en
I18n.fallbacks["en-AU"] = ["en-GB", :en]
I18n.fallbacks["en-CA"] = ["en-GB", :en]