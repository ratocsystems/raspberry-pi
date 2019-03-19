class Gp40sController < ApplicationController
  include CommonControllerModule
  before_action :set_gp40, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /gp40s
  # GET /gp40s.json
  def index
    @gp40s = Gp40.all
    @gp40s = duration(@gp40s, params)
  end

  # GET /gp40s/1
  # GET /gp40s/1.json
  def show
  end

  # GET /machines/:machine_id/gp40
  # GET /machines/:machine_id/gp40.json
  def list
    @gp40s = Machine.find(params[:machine_id]).gp40s.order(:date)
    @gp40s = duration(@gp40s, params)

    sort_ad()
    set_graph()

    if 0 == @gp40s.size
      @last = Machine.find(params[:machine_id]).gp40s.order(:date).last
    end
  end

  # GET /machines/:machine_id/gp40s
  # GET /machines/:machine_id/gp40s.json
  def group
    @gp40s = Gp40.find_measure_group(params[:gp40_id], params[:machine_id])

    sort_ad()
    set_graph()
  end

  # GET /gp40s/1/edit
  def edit
  end

  # POST /gp40s
  # POST /gp40s.json
  def create
    @type   = params[:type]
    item    = params.require(:item)
    @mac    = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new

    data.each do |d|
      ads = Array.new

      ad_list = d.require(:ads)
      ad_list.each do |ad_data|
        ads << Ad.new(ad_data.permit(:channel, :value, :range))
      end

      gp40 = machine.gp40s.create(d.permit(:date, :beginning))
      gp40.ads = ads

      @result << gp40
    end

    render :status => :created
  end

  # PATCH/PUT /gp40s/1
  # PATCH/PUT /gp40s/1.json
  def update
    respond_to do |format|
      if @gp40.update(gp40_params)
        format.html { redirect_to @gp40, notice: 'Gp40 was successfully updated.' }
        format.json { render :show, status: :ok, location: @gp40 }
      end
    end
  end

  # DELETE /gp40s/1
  # DELETE /gp40s/1.json
  def destroy
    @gp40.destroy
    respond_to do |format|
      format.html { redirect_to gp40s_url, notice: 'Gp40 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gp40
      @gp40 = Gp40.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gp40_params
      params.require(:gp40).permit(:machine_id, :date, :beginning)
    end

    # GP40の計測値から電圧を求める
    #
    # @param  [Integer] ad AD値
    # @param  [Integer] range レンジ設定値
    #
    # @return [Integer] 計算した電圧値
    def calc_volte(ad, range)
      coef   = [ 5.00,   2.50,  1.25, 0.625, 0.3125,  2.50,  1.25, 0.625, 0.3125]
      offset = [0x800,  0x800, 0x800, 0x800,  0x800, 0x000, 0x000, 0x000,  0x000]

      return (ad - offset[range]) * coef[range] / 1000;
    end

    # AD値をチャネル番号でソートした結果を用意する。対応チャネルのデータがないときはnil。
    def sort_ad
      return if @gp40s.nil?

      @gp40s.each do |gp40|
        ad_data = Array.new

        8.times do |n|
          ad_data[n] = nil

          gp40.ads.each do |ad|
            if n == ad.channel
              ad_data[n] = {:value => ad.value, :range => ad.range, :volte =>calc_volte(ad.value, ad.range) }
              break
            end
          end
        end
        gp40.channel = ad_data
      end
    end

    # グラフデータ作成
    def set_graph
      unless @gp40s.nil?
        @graph = Array.new
        graph_data = Array.new
        8.times do |n|
          graph_data[n] = Array.new
        end

        @gp40s.each do |gp40|
          8.times do |n|
            graph_data[n] << [gp40.date, gp40.channel[n][:volte]] if false == gp40.channel[n].nil?
          end
        end

        8.times do |n|
          @graph << {name: "CH#{n}", data: graph_data[n]}
        end
      end
    end
end
