class Communication < ApplicationRecord
  include TagsConcern
  include FlagBitsConcern

  STATUS_NEW = 0
  STATUS_SCHEDULED = 1
  STATUS_DELIVERING = 2
  STATUS_COMPLETE = 3
  STATUS_ARCHIVED = 4

  belongs_to :user
  belongs_to :template

  def status_string
    return 'New'
  end
end
