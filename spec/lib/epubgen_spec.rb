# coding: utf-8

require './lib/epubgen'

TARGET_DIR = './spec/sample/snedronningen'
OUT_DIR = ''

describe Epubgen do
  before do
    @epubgen = Epubgen.new(TARGET_DIR, OUT_DIR)
  end
end
