class FallsController < ApplicationController
  include CommonControllerModule
  before_action :set_fall, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /falls
  # GET /falls.json
  def index
    @falls = Fall.all
    @falls = duration(@falls, params)
  end

  # GET /falls/1
  # GET /falls/1.json
  def show
  end

  # GET /machines/:machine_id/fall
  # GET /machines/:machine_id/fall.json
  def list
    @falls = Machine.find(params[:machine_id]).falls.order(:date)
    @falls = duration(@falls, params)

    set_graph

    if 0 == @falls.size
      @last = Machine.find(params[:machine_id]).falls.order(:date).last
    end
  end

  # GET /machines/:machine_id/falls
  # GET /machines/:machine_id/falls.json
  def group
    @falls = Fall.find_measure_group(params[:fall_id], params[:machine_id])

    set_graph
  end

  # GET /falls/1/edit
  def edit
  end

  # POST /falls
  # POST /falls.json
  def create
    @type   = params[:type]
    item    = params.require(:item)
    @mac    = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new
    data.each do |d|
      @result << machine.falls.create(d.permit(:count, :date, :beginning))
    end

    render :status => :created
  end

  # PATCH/PUT /falls/1
  # PATCH/PUT /falls/1.json
  def update
    respond_to do |format|
      if @fall.update(fall_params)
        format.html { redirect_to @fall, notice: 'Fall was successfully updated.' }
        format.json { render :show, status: :ok, location: @fall }
      end
    end
  end

  # DELETE /falls/1
  # DELETE /falls/1.json
  def destroy
    @fall.destroy
    respond_to do |format|
      format.html { redirect_to falls_url, notice: 'Fall was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fall
      @fall = Fall.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fall_params
      params.require(:fall).permit(:count, :machine_id, :date)
    end

    # グラフデータ作成
    def set_graph
      unless @falls.nil?
        @graph = Array.new
        graph_data = Array.new
        @falls.each do |f|
          graph_data << [f.date, f.count]
        end

        @graph << {name: "count", data: graph_data}
      end
    end
end
