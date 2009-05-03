class SearchEngine < ActiveRecord::Base
  ENGINE = /\ApageTracker._addOrganic\(\"(.+?)\",\"(.+?)\"\);\Z/
  GENERIC_TLDS = ['com', 'net', 'org', 'museum', 'biz', 'info']
  
  # Search engine list courtesy of
  # http://www.antezeta.com/blog/google-analytics-search-engines
  # the file is at http://www.antezeta.com/j/gase.js
  # It's in javascript, we'll import it into the database
  # pageTracker._addOrganic("google.co.uk","q");
  def self.import_javascript_list(filename)
    Rails.logger.info "Importing search engine database: #{filename}"
    File.read(filename).each do |line|
      if data = line.match(ENGINE)
        engine = self.find_by_host(data[1]) || new
        engine.attributes = {:host => data[1], :query_param => data[2]}
        country = engine.host.split('.')
        if country.size > 1 && !GENERIC_TLDS.include?(country.last)
          engine.country = country.last
          engine.save!
        end
      end
    end
  end
  
  
end
