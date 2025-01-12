class HomeController < ApplicationController
  def index
    @email = current_user # This will show the user's ID from Supabase
  end
end
