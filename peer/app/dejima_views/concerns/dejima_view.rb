module DejimaView
  extend ActiveSupport::Concern

  class_methods do
    def view_attribute(*attrs)
      puts "Define attributes => #{attrs}"
    end
  end
end
