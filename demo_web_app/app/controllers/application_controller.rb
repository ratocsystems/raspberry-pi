class ApplicationController < ActionController::Base
  before_action :sesstion_initialize

  # session初期化
  def sesstion_initialize
    if session[:autoupdate].nil?
      session[:autoupdate] = false
    end
  end

  # 自動更新ON/OFF切り替え
  def autoupdate
    if "on" == params[:autoupdate]
      session[:autoupdate] = true
    else
      session[:autoupdate] = false
    end

    redirect_to params[:redirect]
  end
end

