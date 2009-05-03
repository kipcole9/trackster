if RAILS_ENV == "development"
  ENV['PATH'] = '/usr/local/bin:' + ENV['PATH']
  ENV['MAGICK_HOME'] = '/usr/local/ImageMagick-6.5.0'
  ENV['DYLD_LIBRARY_PATH'] = '/usr/local/ImageMagick-6.5.0/lib'
end
