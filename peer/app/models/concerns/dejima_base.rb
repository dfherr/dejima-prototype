module DejimaBase
  extend ActiveSupport::Concern

  included do
    self.dejima_views = "test"
  end

  class_methods do
    attr_accessor :dejima_views

    def link_dejima_views(views)
      self.dejima_views = views
      puts "Linked dejima views on #{self} => #{views}"
    end
  end
end
