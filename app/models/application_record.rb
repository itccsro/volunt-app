class ApplicationRecord < ActiveRecord::Base
  include SerializationConcern
  self.abstract_class = true

end
