require 'active_support'
module CommonControllerModule
  extend ActiveSupport::Concern

  included do
    private :duration
  end

  #
  # 取得する測定日時の範囲指定条件を追加する
  #
  # @param          [ActiveBase]  values  範囲指定するモデルデータ
  # @param          [Hash]        params  日付指定
  # @option params  [String]      :date   日付単位での指定データ
  # @option params  [String]      :from   時間指定時の開始日時
  # @option params  [String]      :to     時間指定時の終了日時
  #
  # @return [ActiveBase]  検索条件を付けたモデルデータ
  def duration(values, params)
    if date_valid?(params[:from]) && date_valid?(params[:to])
      from   = Time.parse(params[:from])
      to     = Time.parse(params[:to]) + 1.second
      range  = from.in_time_zone...to.in_time_zone
      values = values.where(date: range)
    elsif date_valid?(params[:date])
      date   = Time.parse(params[:date])
      values = values.where(date: date.in_time_zone.all_day)
    end

    return values
  end

  #
  # Time.parse成功判定
  #
  # @param  [String]  str 日時文字列
  #
  # @return [Boolean] パース成功可否
  def date_valid?(str)
    !! Time.parse(str) rescue false
  end
end
