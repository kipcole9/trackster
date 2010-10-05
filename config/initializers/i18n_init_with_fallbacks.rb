# Include all the available goodies for I18n speedup.
# Note these probably are quite different for Rails 3
I18n::Backend::Simple.send(:include, I18n::Backend::InterpolationCompiler)
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n::Backend::Simple.send(:include, I18n::Backend::Cldr)

# This is our fallback strategy - needs updating whenever a new locale is added
I18n.fallbacks["en-US"] = :en
I18n.fallbacks["en-GB"] = :en
I18n.fallbacks["en-AU"] = ["en-GB", :en]
I18n.fallbacks["en-CA"] = ["en-GB", :en]