class SurveysController < ApplicationController
  include CommonControllerModule
  before_action :set_survey, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :post

  # GET /surveys
  # GET /surveys.json
  def index
    @surveys = Survey.all
    @surveys = duration(@surveys, params)
  end

  # GET /surveys/1
  # GET /surveys/1.json
  def show
  end

  # GET /machines/:machine_id/survey
  # GET /machines/:machine_id/survey.json
  def list
    @surveys = Machine.find(params[:machine_id]).surveys.order(:date)
    @surveys = duration(@surveys, params)

    set_graph

    if 0 == @surveys.size
      @last = Machine.find(params[:machine_id]).surveys.order(:date).last
    end
  end

  # GET /machines/:machine_id/surveys
  # GET /machines/:machine_id/surveys.json
  def group
    @surveys = Survey.find_measure_group(params[:survey_id], params[:machine_id])

    set_graph
  end

  # GET /surveys/1/edit
  def edit
  end

  # POST /surveys
  # POST /surveys.json
  def create
    @type   = params[:type]
    item    = params.require(:item)
    @mac    = item.require(:machine)
    machine = Machine.check(@mac.permit(:mac))

    data = item.require(:data)
    @result = Array.new
    data.each do |d|
      @result << machine.surveys.create(d.permit(:distance, :date, :beginning))
    end

    render :status => :created
  end

  # PATCH/PUT /surveys/1
  # PATCH/PUT /surveys/1.json
  def update
    respond_to do |format|
      if @survey.update(survey_params)
        format.html { redirect_to @survey, notice: 'Survey was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey }
      end
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.json
  def destroy
    @survey.destroy
    respond_to do |format|
      format.html { redirect_to surveys_url, notice: 'Survey was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey
      @survey = Survey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_params
      params.require(:survey).permit(:distance, :machine_id, :date)
    end

    # グラフデータ作成
    def set_graph
      unless @surveys.nil?
        @graph = Array.new
        graph_data = Array.new
        @surveys.each do |f|
          graph_data << [f.date, f.distance]
        end

        @graph << {name: "Distance", data: graph_data}
      end
    end
end
