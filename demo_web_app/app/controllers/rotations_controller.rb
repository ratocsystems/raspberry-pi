class RotationsController < ApplicationController
  include CommonControllerModule
  before_action :set_rotation, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /rotations
  # GET /rotations.json
  def index
    @rotations = Rotation.all
    @rotations = duration(@rotations, params)
  end

  # GET /rotations/1
  # GET /rotations/1.json
  def show
  end

  # GET /machines/:machine_id/rotation
  # GET /machines/:machine_id/rotation.json
  # 機種ごとの一覧を表示する
  def list
    @rotations = Machine.find(params[:machine_id]).rotations.order(:date)
    @rotations = duration(@rotations, params)

    set_graph

    if 0 == @rotations.size
      @last = Machine.find(params[:machine_id]).rotations.order(:date).last
    end
  end

  # GET /machines/:machine_id/rotations
  # GET /machines/:machine_id/rotations.json
  # 機種ごとの一覧を測定グループごとに表示する
  def group
    @rotations = Rotation.find_measure_group(params[:rotation_id], params[:machine_id])

    set_graph
  end

  # GET /rotations/1/edit
  def edit
  end

  # POST /rotations
  # POST /rotations.json
  def create
    @type = params[:type]
    item = params.require(:item)
    @mac = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new
    data.each do |d|
      @result << machine.rotations.create(d.permit(:rpm, :angle, :date, :beginning))
    end

    render :status => :created
  end

  # PATCH/PUT /rotations/1
  # PATCH/PUT /rotations/1.json
  def update
    respond_to do |format|
      if @rotation.update(rotation_params)
        format.html { redirect_to @rotation, notice: 'Rotation was successfully updated.' }
        format.json { render :show, status: :ok, location: @rotation }
      end
    end
  end

  # DELETE /rotations/1
  # DELETE /rotations/1.json
  def destroy
    @rotation.destroy
    respond_to do |format|
      format.html { redirect_to rotations_url, notice: 'Rotation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rotation
      @rotation = Rotation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rotation_params
      params.require(:rotation).permit(:rpm, :angle, :machine_id, :date)
    end

    # グラフデータ作成
    def set_graph
      unless @rotations.nil?
        @graph = Array.new
        graph_data = Array.new
        @rotations.each do |r|
          graph_data << [r.date, r.rpm]
        end

        @graph << {name: "回転数", data: graph_data}
      end
    end
end
