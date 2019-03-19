# String オープンクラス
class String
  # 出力する文字列カラー表示対応
  def color(colorname)
    colorno = { red: 31, green: 32, yellow: 33, blue: 34, magenta: 35, cyan: 36, white: 37 }
    "\e[#{colorno[colorname]}m#{self}\e[0m"
  end
end
