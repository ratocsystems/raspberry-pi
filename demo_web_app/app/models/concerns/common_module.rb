require 'active_support'
module CommonModule
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    #
    # 指定したIDから測定単位でのデータ取得
    # IDに一致するデータがない場合は最新の測定データを返す
    #
    # @param  [Integer] id          取得対象のデータID
    # @param  [Integer] machine_id  取得対象の機器ID
    #
    # @return [ActiveBase]  条件に一致したデータ
    def find_measure_group(id, machine_id)
      result    = nil
      beginning = nil

      # 指定された条件に一致したときはそのデータを含む測定時間を取得
      if false == id.nil? && self.exists?(id: id, machine_id: machine_id)
        values    = self.find(id)
        beginning = values.beginning unless values.nil?

      # 指定された条件に一致しなかったときは機器IDが一致する最新の測定時間を取得
      else
        value = self.where(["machine_id = ?", machine_id]).order(:beginning).select(:beginning).distinct.last
        beginning = value.beginning unless value.nil?
      end

      unless beginning.nil?
        result = self.where(["beginning = ?", beginning]).order(:date)
      end

      return result
    end
  end

  #
  # ひとつ前の測定グループデータを取得する
  # データがないときはnilを返す
  #
  # @return [Integer] ひとつ前のグループのデータID
  def prev_group
    id = nil
    value = self.class.where("machine_id = ? AND beginning < ?", self.machine_id, self.beginning).order(beginning: :desc).first
    id = value.id unless value.nil?

    return id
  end

  #
  # ひとつ次の測定グループデータを取得する
  # データがないときはnilを返す
  #
  # @return [Integer] ひとつ前のグループのデータID
  def next_group
    id = nil
    value = self.class.where("machine_id = ? AND beginning > ?", self.machine_id, self.beginning).order(:beginning).first
    id = value.id unless value.nil?

    return id
  end

  #
  # 前日以前のデータの日付を取得
  # データがないときはnilを返す
  #
  # @return [Date] 前日以前のデータ日付
  def prev_day
    id = nil
    value = self.class.where("machine_id = ? AND date < ?", self.machine_id, self.date.beginning_of_day).order(date: :desc).first
    date = value.date unless value.nil?

    return date
  end

  #
  # 翌日以降のデータの日付を取得
  # データがないときはnilを返す
  #
  # @return [Date] 翌日以降のデータ日付
  def next_day
    id = nil
    value = self.class.where("machine_id = ? AND date > ?", self.machine_id, self.date.end_of_day).order(:date).first
    date = value.date unless value.nil?

    return date
  end

end
