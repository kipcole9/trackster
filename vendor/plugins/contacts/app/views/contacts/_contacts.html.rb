store render :partial => 'contacts/contact', :collection => (@contacts || @people || @organizations), :as => :contacts
clear
store will_paginate(@contacts  || @people || @organizations)