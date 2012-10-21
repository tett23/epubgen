# coding: utf-8

module Helper
  def join_path(*pathes)
    pathes.join(File::SEPARATOR)
  end
end
