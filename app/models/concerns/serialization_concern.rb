module SerializationConcern
  extend ActiveSupport::Concern

  def serializer_class
    "#{self.class.name}Serializer".constantize
  end
end
