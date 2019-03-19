class WbgtsController < ApplicationController
  include CommonControllerModule
  before_action :set_wbgt, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /wbgts
  # GET /wbgts.json
  def index
    @wbgts = Wbgt.all
    @wbgts = duration(@wbgts, params)
  end

  # GET /wbgts/1
  # GET /wbgts/1.json
  def show
  end

  # GET /machines/:machine_id/wbgt
  # GET /machines/:machine_id/wbgt.json
  def list
    @wbgts = Machine.find(params[:machine_id]).wbgts.order(:date)
    @wbgts = duration(@wbgts, params)

    set_graph

    if 0 == @wbgts.size
      @last = Machine.find(params[:machine_id]).wbgts.order(:date).last
    end
  end

  # GET /machines/:machine_id/wbgts
  # GET /machines/:machine_id/wbgts.json
  def group
    @wbgts = Wbgt.find_measure_group(params[:wbgt_id], params[:machine_id])

    set_graph
  end

  # GET /wbgts/1/edit
  def edit
  end

  # POST /wbgts
  # POST /wbgts.json
  def create
    @type   = params[:type]
    item    = params.require(:item)
    @mac    = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new
    data.each do |d|
      @result << machine.wbgts.create(d.permit(:black, :dry, :wet, :humidity, :wbgt_data, :date, :beginning))
    end

    render :status => :created
  end

  # PATCH/PUT /wbgts/1
  # PATCH/PUT /wbgts/1.json
  def update
    respond_to do |format|
      if @wbgt.update(wbgt_params)
        format.html { redirect_to @wbgt, notice: 'Wbgt was successfully updated.' }
        format.json { render :show, status: :ok, location: @wbgt }
      end
    end
  end

  # DELETE /wbgts/1
  # DELETE /wbgts/1.json
  def destroy
    @wbgt.destroy
    respond_to do |format|
      format.html { redirect_to wbgts_url, notice: 'Wbgt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wbgt
      @wbgt = Wbgt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wbgt_params
      params.require(:wbgt).permit(:black, :dry, :wet, :humidity, :wbgt_data, :machine_id, :date, :beginning)
    end

    # グラフデータ作成
    #
    # 各温度計とWBGT指標データを登録
    def set_graph
      unless @wbgts.nil?
        @graph = Array.new
        graph_data = Hash.new
        graph_data[:wbgt] = Array.new
        graph_data[:black] = Array.new
        graph_data[:dry] = Array.new
        graph_data[:wet] = Array.new

        @wbgts.each do |f|
          graph_data[:wbgt] << [f.date, f.wbgt_data]
          graph_data[:black] << [f.date, f.black]
          graph_data[:dry] << [f.date, f.dry]
          graph_data[:wet] << [f.date, f.wet]
        end

        @graph << {name: "WBGT",   data: graph_data[:wbgt]}
        @graph << {name: "黒球計", data: graph_data[:black]}
        @graph << {name: "乾球計", data: graph_data[:dry]}
        @graph << {name: "湿球計", data: graph_data[:wet]}
      end
    end
end
