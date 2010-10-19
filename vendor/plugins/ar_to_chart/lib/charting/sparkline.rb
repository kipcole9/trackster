module Charting
  class Sparkline
    include ActionController::UrlWriter
    
    DEFAULT_OPTIONS = { 
                        :type               => 'bar', 
                        :height             => '20', 
                        :background_color   => '#ddd', 
                        :above_color        => 'rgb(25,135,213)', 
                        :upper              => '0'
                      }
      
    def initialize(data_source, column, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @chart = graph_data(data_source, column, @options)      
    end
    
    def render_chart
      if @chart
        sparkline_tag @chart, @options
      else
        I18n.t('no_data_for_chart')
      end
    end

    def graph_data(data_source, column, options, &block) 
      return nil if data_source.empty?
      series_from_data(data_source, column, options)
    end
    
    def series_from_data(data_source, column, options)
      data_source.inject([]){|result_array, item| result_array << item[column].to_i}
    end
    
  	def sparkline_tag(results=[], options={})
  		url = { :controller => 'sparklines', :results => results.join(',') }
  		options = url.merge(options)
  		"<img src=\"#{ sparklines_path options }\" class=\"#{options[:class] || 'sparkline'}\" alt=\"Sparkline Graph\" />"
  	end
  end
end