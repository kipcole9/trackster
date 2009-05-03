h4 link_to(redirect.name, redirect_url(redirect.id))
p "#{t('.redirect_to')}: #{link_to redirect.url, redirect.url}"
p "#{t('.redirect_from')}: #{link_to redirector_url(redirect.redirect_url), redirector_url(redirect.redirect_url)}"


