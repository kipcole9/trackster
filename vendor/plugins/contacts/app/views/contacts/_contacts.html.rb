store render(:partial => 'contacts/contact', :collection => contacts, :as => :contacts)
clear
paginate contacts