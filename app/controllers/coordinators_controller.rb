class CoordinatorsController < ApplicationController
  include ProfilesControllerConcern
  include ProfileDefaultAuthorization

  profile_controller :coordinator, 'Advisor'
end

