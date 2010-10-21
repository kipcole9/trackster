# encoding: UTF-8

module ActiveSupport
  module Inflector
    def ordinalize(number)
      rules = I18n.t 'number.ordinals', :default => "fallback"
      
      # Assume English for compat
      rules = {
        :'\d{0,}11\Z' => "%dth",
        :'\d{0,}12\Z' => "%dth",
        :'\d{0,}13\Z' => "%dth",
        :'\d{0,}1\Z'  => "%dst",
        :'\d{0,}2\Z'  => "%dnd",
        :'\d{0,}3\Z'  => "%drd",
        :other => "%dth"
      } if rules == "fallback"
      
      match = rules.find do |rule|
        number.to_s =~ Regexp.new(rule[0].to_s)
      end
      match = match[1] unless match.nil?
      
      match ||= rules[:other]
      
      match % number
    end
  end
end