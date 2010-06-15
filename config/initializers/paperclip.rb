# Development needs help in order to find imagemagick
if Rails.env == "development"
  Paperclip.options[:command_path] = "/opt/local/bin"
end


