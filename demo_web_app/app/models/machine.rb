#
# 機器テーブル
#
class Machine < ApplicationRecord
  has_many :rotations
  has_many :slopes
  has_many :falls
  has_many :surveys
  has_many :wbgts
  has_many :gp10s
  has_many :gp40s

  #
  # machineテーブルからmacカラムと一致するデータを返す
  # 一致するデータがないときは新規データを作成して返す
  #
  # @param          [Hash]    params  macデータ
  # @option params  [String]  :mac    macアドレス
  #
  # @return [Hash]  macアドレスが一致したデータ
  #
  def self.check(params)
    machine = Machine.find_by(mac: params[:mac])

    if machine.nil?
      machine = Machine.create(:mac => params[:mac])
    end

    return machine
  end
end
