require File.join(File.dirname(__FILE__), 'common.rb')

#
#
#
describe Snap::Request do
  it '(path_info_fragments return) should return an array' do
    r=Snap::Request.new(new_rack_env('/'))
    r.path_info_slices.class.should == Array
  end
  
  it '(path_info_fragments return) should always start with a /' do
    r=Snap::Request.new(new_rack_env('a/test//to/a/path/'))
    r.path_info_slices[0].should == '/'
    r=Snap::Request.new(new_rack_env('/a/test//to/a/path/'))
    r.path_info_slices[0].should == '/'
  end
  
  it 'should remove duplicate slashes when responding to path_info_fragments' do
    r=Snap::Request.new(new_rack_env('a/test//to/a/path/'))
    r.path_info_slices.should == ['/', 'a', 'test', 'to', 'a', 'path']
  end
end