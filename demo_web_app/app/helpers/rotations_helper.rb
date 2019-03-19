module RotationsHelper
  # 停止角度からルーレットの数字を取得
  def get_roulette_no(angle)
    rnum = [ 0,26,3,35,12,28,7,29,18,22,9,31,14,20,1,33,16,24,5,10,23,8,30,11,36,13,27,6,34,17,25,2,21,4,19,15,32 ]

    n = angle.quo(360.quo(37)).to_i

    return rnum[n]
  end

  # 停止角度からルーレットの停止位置を、zero、odd、evenのいずれかを返す
  def get_roulette_position(angle)
    n = angle.quo(360.quo(37)).to_i

    if n.zero?
      pos = 'zero'
    elsif n.even?
      pos = 'even'
    elsif n.odd?
      pos = 'odd'
    end

    return pos
  end
end
