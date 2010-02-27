store render :partial => 'contacts/contact', :collection => (@contacts || @people || @organizations), :as => :contacts
clear
paginate(@contacts  || @people || @organizations)