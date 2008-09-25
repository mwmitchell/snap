require 'test/unit'
require 'snap'

class CoreExtTest < Test::Unit::TestCase
  
  def test_string_trim
    assert_equal 'path/to/something', '//path/to/something////'.trim('/')
    assert_equal 'path/to/something', ';//path/to/something////'.trim('/', ';')
    assert_equal 'path/to/something', ';;;;;//path/to/something;'.trim(';', '/')
    assert_equal 'path/to/something', ';;;;;//path/to/something;///'.trim(';', '/', '-', '0')
  end
  
  def test_string_trim!
    a = '//path/to/something////'
    a.trim!('/')
    assert_equal 'path/to/something', a
    
    b = ';//path/to/something////'
    b.trim!('/', ';')
    assert_equal 'path/to/something', b
    
    c = ';;;;;//path/to/something;'
    c.trim!(';', '/')
    assert_equal 'path/to/something', c
    
    d = ';;;;;//path0/to/-something;///'
    d.trim!(';', '/', '-', '0')
    assert_equal 'path0/to/-something', d
  end
  
  def test_string_dedup
    assert_equal 'path/to/something/', 'path/////to/something//'.dedup('/')
    assert_equal 'path/to/;something/', 'path/////to/;something//'.dedup('/')
    assert_equal 'path/to/;something/', 'path/////to/;something//'.dedup('/', ';')
  end
  
  def test_string_dedup!
    a = 'path/////to/something//'
    a.dedup!('/')
    assert_equal 'path/to/something/', a
    
    b = 'path/////to/;something//'
    b.dedup!('/')
    assert_equal 'path/to/;something/', b
    
    c = 'path/////to/;something//'
    c.dedup!('/', ';')
    assert_equal 'path/to/;something/', c
  end
  
  def test_string_cleanup
    assert_equal '--a-test-;-', ';;;--a-test-;;-'.cleanup(';')
    assert_equal 'a-;test', '--a---;;;;;test-;;-'.cleanup('-', ';')
    assert_equal 'a-;test', '--a---;;;;;test-;;-'.cleanup('-', ';')
  end
  
  def test_string_cleanup!
    a = ';;;--a-test-;;-'
    a.cleanup!(';')
    assert_equal '--a-test-;-', a
    
    b = '--a---;;;;;test-;;-'
    b.cleanup!('-', ';')
    assert_equal 'a-;test', b
    
    c = '--a---;;;;;test-;;-'
    c.cleanup!('-', ';')
    assert_equal 'a-;test', c
  end
  
end