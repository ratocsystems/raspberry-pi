class HomeController < ApplicationController

  # GET /
  def index
    @machines = Machine.all
  end

end
