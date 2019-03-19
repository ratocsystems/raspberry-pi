class Gp10sController < ApplicationController
  include CommonControllerModule
  before_action :set_gp10, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /gp10s
  # GET /gp10s.json
  def index
    @gp10s = Gp10.all
    @gp10s = duration(@gp10s, params)
  end

  # GET /gp10s/1
  # GET /gp10s/1.json
  def show
  end

  # GET /machines/:machine_id/gp10
  # GET /machines/:machine_id/gp10.json
  def list
    @gp10s = Machine.find(params[:machine_id]).gp10s.order(:date)
    @gp10s = duration(@gp10s, params)

    if 0 == @gp10s.size
      @last = Machine.find(params[:machine_id]).gp10s.order(:date).last
    end
  end

  # GET /machines/:machine_id/gp10s
  # GET /machines/:machine_id/gp10s.json
  def group
    @gp10s = Gp10.find_measure_group(params[:gp10_id], params[:machine_id])
  end

  # GET /gp10s/1/edit
  def edit
  end

  # POST /gp10s
  # POST /gp10s.json
  def create
    @type   = params[:type]
    item    = params.require(:item)
    @mac    = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new
    data.each do |d|
      @result << machine.gp10s.create(d.permit(:di, :date, :beginning))
    end

    render :status => :created
  end

  # PATCH/PUT /gp10s/1
  # PATCH/PUT /gp10s/1.json
  def update
    respond_to do |format|
      if @gp10.update(gp10_params)
        format.html { redirect_to @gp10, notice: 'Gp10 was successfully updated.' }
        format.json { render :show, status: :ok, location: @gp10 }
      end
    end
  end

  # DELETE /gp10s/1
  # DELETE /gp10s/1.json
  def destroy
    @gp10.destroy
    respond_to do |format|
      format.html { redirect_to gp10s_url, notice: 'Gp10 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gp10
      @gp10 = Gp10.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gp10_params
      params.require(:gp10).permit(:di, :machine_id, :date, :beginning)
    end
end
