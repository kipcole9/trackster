# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# For producing xml in an Xcelsius-specific format
Mime::Type.register_alias "text/xml", :xcelsius

# For Vcards: http://en.wikipedia.org/wiki/VCard
Mime::Type.register       "text/x-vcard", :vcard
Mime::Type.register_alias "text/x-vcard", :vcf

# For PDF output
Mime::Type.register_alias "text/html", :pdf