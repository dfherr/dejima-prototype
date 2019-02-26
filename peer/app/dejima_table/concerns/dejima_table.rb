module DejimaTable
  extend ActiveSupport::Concern

  included do
    self.dejima_attributes
  end

  class_methods do

    attr_accessor :dejima_attributes

    def define_attribute(*attrs)
      self.dejima_attributes=attrs
      puts "Defined dejima attributes on #{self} => #{attrs}"
    end
  end
end
