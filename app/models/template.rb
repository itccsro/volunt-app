class Template < ApplicationRecord
  include TagsConcern
  include FlagBitsConcern

  validates :name, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :body, presence: true

end
