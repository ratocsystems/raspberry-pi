class SlopesController < ApplicationController
  include CommonControllerModule
  before_action :set_slope, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /slopes
  # GET /slopes.json
  def index
    @slopes = Slope.all
    @slopes = duration(@slopes, params)
  end

  # GET /slopes/1
  # GET /slopes/1.json
  def show
  end

  # GET /machines/:machine_id/slope
  # GET /machines/:machine_id/slope.json
  def list
    @slopes = Machine.find(params[:machine_id]).slopes.order(:date)
    @slopes = duration(@slopes, params)

    set_graph

    if 0 == @slopes.size
      @last = Machine.find(params[:machine_id]).slopes.order(:date).last
    end
  end

  # GET /machines/:machine_id/slopes
  # GET /machines/:machine_id/slopes.json
  def group
    @slopes = Slope.find_measure_group(params[:slope_id], params[:machine_id])

    set_graph
  end

  # GET /slopes/1/edit
  def edit
  end

  # POST /slopes
  # POST /slopes.json
  def create
    @type = params[:type]
    item = params.require(:item)
    @mac = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new
    data.each do |d|
      @result << machine.slopes.create(d.permit(:x, :y, :z, :date, :beginning))
    end

    render :status => :created
  end

  # PATCH/PUT /slopes/1
  # PATCH/PUT /slopes/1.json
  def update
    respond_to do |format|
      if @slope.update(slope_params)
        format.html { redirect_to @slope, notice: 'Slope was successfully updated.' }
        format.json { render :show, status: :ok, location: @slope }
      end
    end
  end

  # DELETE /slopes/1
  # DELETE /slopes/1.json
  def destroy
    @slope.destroy
    respond_to do |format|
      format.html { redirect_to slopes_url, notice: 'Slope was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_slope
      @slope = Slope.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def slope_params
      params.require(:slope).permit(:x, :y, :z, :machine_id, :date)
    end

    # グラフデータ作成
    def set_graph
      unless @slopes.nil?
        @graph = Array.new
        graph_data = Hash.new
        graph_data[:x] = Array.new
        graph_data[:y] = Array.new
        graph_data[:z] = Array.new

        @slopes.each do |r|
          graph_data[:x] << [r.date, r.x]
          graph_data[:y] << [r.date, r.y]
          graph_data[:z] << [r.date, r.z]
        end

        @graph << {name: "x", data: graph_data[:x]}
        @graph << {name: "y", data: graph_data[:y]}
        @graph << {name: "z", data: graph_data[:z]}
      end
    end
end
