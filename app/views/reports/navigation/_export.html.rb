# cache report_cache_key("reports/navigation/export") do
  panel t('navigation.exports')  do
    block :hidden => true do
      accordion :id => 'export_navigation' do
        accordion_item I18n.t('reports.export.exports') do  
          nav link_to(I18n.t('reports.export.xml'), url_for(params.merge(:format => 'xml')))
          nav link_to(I18n.t('reports.export.xcelsius'), url_for(params.merge(:format => 'xcelsius')))
          nav link_to(I18n.t('reports.export.csv'), url_for(params.merge(:format => 'csv')))
          nav link_to(I18n.t('reports.export.json'), url_for(params.merge(:format => 'json')))
        end
        accordion_item I18n.t('reports.stream.streams') do  
          nav link_to(I18n.t('reports.export.xml'), url_for(params.merge(:format => 'xml', :action => 'stream')))
          nav link_to(I18n.t('reports.export.xcelsius'), url_for(params.merge(:format => 'xcelsius', :action => 'stream')))
          nav link_to(I18n.t('reports.export.csv'), url_for(params.merge(:format => 'csv', :action => 'stream')))
          nav link_to(I18n.t('reports.export.json'), url_for(params.merge(:format => 'json', :action => 'stream')))
        end
      end
    end
  end
# end