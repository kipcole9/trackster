# Delete the <li> if a successful deletion
store <<-EOF
  $('#campaign_listItem_#{params[:id]}').effect('highlight', {}, 500, function(){
    $('#campaign_listMember_#{params[:id]}').remove();
  });
  EOF