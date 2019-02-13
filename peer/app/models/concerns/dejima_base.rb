module DejimaBase
  extend ActiveSupport::Concern

  class_methods do
    def mount_views(*views)
      puts "Mounting #{view}"

    end
  end
end
