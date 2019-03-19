crumb :root do
  link "Home", root_path
end

crumb :machine_rotations do |rotations|
  if rotations.nil?
    link "測定日時", machine_rotations_path
  else
    link rotations.first.date.strftime("%F %T"), machine_rotations_path
  end
  parent :machine_rotation, rotations
end

crumb :machine_rotation do |rotations|
  if rotations.nil?
    link "回転数", machine_rotation_path
  else
    link "回転数", machine_rotation_path({date: rotations.first.date.strftime("%F")})
  end
  parent :root
end

crumb :machine_falls do |falls|
  if falls.nil?
    link "測定日時",machine_falls_path
  else
    link falls.first.date.strftime("%F %T"), machine_falls_path
  end
  parent :machine_fall, falls
end

crumb :machine_fall do |falls|
  if falls.nil?
    link "落下数", machine_fall_path
  else
    link "落下数", machine_fall_path({date: falls.first.date.strftime("%F")})
  end
  parent :root
end

crumb :machine_surveys do |surveys|
  if surveys.nil?
    link "測定日時",machine_surveys_path
  else
    link surveys.first.date.strftime("%F %T"), machine_surveys_path
  end
  parent :machine_survey, surveys
end

crumb :machine_survey do |surveys|
  if surveys.nil?
    link "測距", machine_survey_path
  else
    link "測距", machine_survey_path({date: surveys.first.date.strftime("%F")})
  end
  parent :root
end

crumb :machine_slopes do |slopes|
  if slopes.nil?
    link "測定日時",machine_slopes_path
  else
    link slopes.first.date.strftime("%F %T"), machine_slopes_path
  end
  parent :machine_slope, slopes
end

crumb :machine_slope do |slopes|
  if slopes.nil?
    link "傾き", machine_slope_path
  else
    link "傾き", machine_slope_path({date: slopes.first.date.strftime("%F")})
  end
  parent :root
end

crumb :machine_wbgts do |wbgts|
  if wbgts.nil?
    link "測定日時",machine_wbgts_path
  else
    link wbgts.first.date.strftime("%F %T"), machine_wbgts_path
  end
  parent :machine_wbgt, wbgts
end

crumb :machine_wbgt do |wbgts|
  if wbgts.nil?
    link "WBGT", machine_wbgt_path
  else
    link "WBGT", machine_wbgt_path({date: wbgts.first.date.strftime("%F")})
  end
  parent :root
end

crumb :machine_gp10s do |gp10s|
  if gp10s.nil?
    link "測定日時",machine_gp10s_path
  else
    link gp10s.first.date.strftime("%F %T"), machine_gp10s_path
  end
  parent :machine_gp10, gp10s
end

crumb :machine_gp10 do |gp10s|
  if gp10s.nil?
    link "GP10", machine_gp10_path
  else
    link "GP10", machine_gp10_path({date: gp10s.first.date.strftime("%F")})
  end
  parent :root
end

crumb :machine_gp40s do |gp40s|
  if gp40s.nil?
    link "測定日時",machine_gp40s_path
  else
    link gp40s.first.date.strftime("%F %T"), machine_gp40s_path
  end
  parent :machine_gp40, gp40s
end

crumb :machine_gp40 do |gp40s|
  if gp40s.nil?
    link "GP40", machine_gp40_path
  else
    link "GP40", machine_gp40_path({date: gp40s.first.date.strftime("%F")})
  end
  parent :root
end

