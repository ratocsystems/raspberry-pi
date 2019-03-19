module WbgtsHelper
  # WBGT指標データから運動指針を返す
  def get_wbgt_guide(wbgt)
    if 21 > wbgt
      return {value: 'success', msg: 'ほぼ安全'}
    elsif 25 > wbgt
      return {value: 'info', msg: '注意'}
    elsif 28 > wbgt
      return {value: 'active', msg: '警戒'}
    elsif 31 > wbgt
      return {value: 'warning', msg: '厳重警戒'}
    else
      return {value: 'danger', msg: '運動は原則中止'}
    end
  end
end
