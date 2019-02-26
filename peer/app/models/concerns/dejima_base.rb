module DejimaBase
  extend ActiveSupport::Concern

  included do
    self.dejima_tables = "test"
  end

  class_methods do
    attr_accessor :dejima_tables

    def link_dejima_tables(views)
      self.dejima_tables = views
      puts "Linked dejima views on #{self} => #{views}"
    end
  end
end
