# coding: utf-8

module Helper
  # あとでうまいことひとつにまとめたい
  def join_path(*pathes)
    pathes.join(File::SEPARATOR)
  end

  def Helper.join_path(*pathes)
    pathes.join(File::SEPARATOR)
  end
end
