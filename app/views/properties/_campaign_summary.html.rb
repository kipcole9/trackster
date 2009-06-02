panel t(".#{params[:action]}"), :class => 'table'  do
  block do
    if @campaign_summary.empty?
      h3 t('.no_data_yet')
    else
      store @campaign_summary.to_table
    end
  end
end