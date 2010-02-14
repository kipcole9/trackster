column :width => 9, :id => :contactBlock do
  panel "Contacts" do
    clear do
      section :width => 30, :id => :segments, :title => "Segments" do
        p "Segments"
      end
      section :width => 30, :id => :contacts, :title => "Contacts" do
        p "Contacts"
      end
      section :width => 40, :id => :contactData, :title => "Details" do
        p "Details"
      end
    end
  end
end

column  :width => 3 do
  include 'contacts/navigation'
end

