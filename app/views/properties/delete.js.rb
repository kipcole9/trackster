# Delete the <li> if a successful deletion
store <<-EOF
  $('#property_listItem_#{params[:id]}').effect('highlight', {}, 500, function(){
    $('#property_listMember_#{params[:id]}').remove();
  });
EOF