require 'htmlentities'

module Analytics
  module Params
    private
    def params_to_hash(params)
      result = split_into_parameters(params).inject(Hash.new) do |hash, p|
        var, value = p.split('=')
        hash[var] = CGI.unescape(value) unless value.blank?
        hash
      end
      result
    end

    def split_into_parameters(query_string)
      query_string.blank? ? [] : HTMLEntities.new.decode(query_string).split('&')
    end
  end
end