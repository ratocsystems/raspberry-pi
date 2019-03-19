module Gp40sHelper
  # GP40のレンジ設定の表記文字列取得
  #
  # @param  [Integer] range レンジ設定値
  #
  # @return [String] レンジ表記
  def print_range(range)
    msg = ["±10V" , "±5V", "±2.5V", "±1V", "±0.5V", "0 - 10V", "0 - 5V", "0 - 2.5V", "0 - 1V"]

    return msg[range]
  end
end
