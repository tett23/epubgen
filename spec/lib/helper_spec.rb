# coding: utf-8

require './lib/helper'

class HelperDummyClass
end

describe Helper do
  before do
    @helper = HelperDummyClass.new
    @helper.extend(Helper)
  end

  it 'join_pathが動いているか' do
    @helper.join_path('a', 'b', 'c').should == 'a/b/c'
  end
  it 'join_pathに引数を与えない場合' do
    @helper.join_path().should == ''
  end
  it '特異メソッドとしてjoin_pathを呼び出す' do
    Helper.join_path('a', 'b').should == 'a/b'
  end
end
