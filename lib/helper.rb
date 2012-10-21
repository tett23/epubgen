# coding: utf-8

module Helper
  # あとでうまいことひとつにまとめたい
  def join_path(*pathes)
    (pathes.reject{|v| v.nil? || v==''}).join(File::SEPARATOR)
  end

  def Helper.join_path(*pathes)
    (pathes.reject{|v| v.nil? || v==''}).join(File::SEPARATOR)
  end
end
