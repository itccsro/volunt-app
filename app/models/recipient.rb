class Recipient < ApplicationRecord
  belongs_to :communication
  belongs_to :profile
end
