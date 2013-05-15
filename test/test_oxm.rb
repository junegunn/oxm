# encoding: utf-8
require 'helper'

class TestOxm < Test::Unit::TestCase
  require 'tempfile'
  def test_errors
    str = '
    <?xml version="1.0"?>
    <container attr1="1" attr2="2">
      <item dept="A">
        <volume unit="ml"><![CDATA[ 100 ]]></volume>
        <volume unit="ml"><![CDATA[백]]></volume>
      </item>
      <item dept="B">
        <volume unit="l">200</volume>
        <volume unit="l">300</volume>
      </item>
    </container>
    '

    # Test errors (XML declaration allowed only at the start of the document)
    oxm = OXM.new str
    result = oxm.from_xml('container').to_a
    assert_equal 0, result.length
    assert_equal 1, oxm.errors.length
    assert_equal 0, oxm.warnings.length

    # Test no-errors
    oxm = OXM.new str.strip
    result = oxm.from_xml('container').to_a
    assert_equal 1, result.length
    assert_equal 0, oxm.errors.length
    assert_equal 0, oxm.warnings.length

    # Test empty IO
    tf = Tempfile.new('oxm')
    tf << str.strip
    tf.flush

    oxm = OXM.new File.open(tf.path)
    result = oxm.from_xml('container').to_a
    assert_equal 1, result.length
    assert_equal 0, oxm.errors.length
    assert_equal 0, oxm.warnings.length

    result = oxm.from_xml('container').to_a
    assert_equal 0, result.length
    assert_equal 2, oxm.errors.length
    assert_equal 0, oxm.warnings.length
  end

  def test_from_xml_string
    str = '
    <?xml version="1.0"?>
    <container attr1="1" attr2="2">
      <item dept="A">
        <volume unit="ml"><![CDATA[ 100 ]]></volume>
        <volume unit="ml"><![CDATA[200]]></volume>
      </item>
      <item dept="B">
        <volume unit="l">200</volume>
        <volume unit="l">300</volume>
      </item>
      <item dept="C">
        <volume unit="l">300</volume>
        <volume unit="ml">400</volume>
      </item>
      <item dept="D">
        <volume unit="L">500</volume>
        <volume></volume>
      </item>
    </container>
    '

    # STRIP
    str = str.strip

    tf = Tempfile.new('oxm')
    tf << str
    tf.flush

    [lambda { str }, lambda { File.open(tf.path) }].each do |input|
      result = OXM.from_xml(input.call, 'container')
      if defined?(Enumerable::Enumerator)
        assert result.is_a?(Enumerable::Enumerator)
      else
        assert result.is_a?(Enumerator)
      end
      result = result.to_a
      assert_equal 1, result.length
      assert_equal "", result.first.to_s
      assert_equal({'attr1' => '1', 'attr2' => '2'}, result.first.attributes)
      assert_equal(result.first.children, result.first.elements)
      assert_equal(%w[item], result.first.children.keys)
      assert_equal(4, result.first.elements.values.first.length)
      assert_equal '1', result.first['attr1']
      assert_equal '2', result.first['attr2']
      assert_equal nil, result.first['attr3']

      assert       result.map(&:item).all? { |items| items.is_a? Array }
      assert       result.map(&:item).map(&:first).all? { |i| i.tag == 'item' }
      assert       result.first.item.first.volume.all? { |i| i.cdata? }
      assert       result.first.item.first.volume.all? { |i| i.content == i.to_s }
      assert       result.first.item.last.volume.all? { |i| i.cdata? == false }

      container = result.first
      assert container.compact!.equal?(container) # Object identity
      assert container.item.is_a?(Array)

      result = OXM.from_xml(input.call, 'container/item').to_a
      assert_equal 4, result.length

      item = result.last
      item.compact!
      assert item.volume.is_a?(OXM::Object)
      assert_equal '500', item.volume.to_s
      assert_equal 'L', item.volume['unit']

      result = OXM.from_xml(input.call, 'container/item/volume').to_a
      assert_equal 8, result.length
      assert_equal %w[100 200 200 300 300 400 500] + [""], result.map(&:to_s)
      assert_equal %w[ml ml l l l ml L] + [nil], result.map { |e| e['unit'] }
      assert_equal result.map { |e| e['unit'] }, result.map { |e| e[:unit] }
      assert_equal '<volume unit="ml"><![CDATA[100]]></volume>', result.first.to_xml

      vol = result[-3]
      assert_equal '<volume unit="ml">400</volume>', vol.to_xml
      vol['unit'] = 'L'
      assert_equal '<volume unit="L">400</volume>', vol.to_xml
      vol.content = 500
      assert_equal '<volume unit="L">500</volume>', vol.to_xml
      vol.content = 550
      assert_equal '<volume unit="L">550</volume>', vol.to_xml
      vol.cdata = 600
      assert_equal '<volume unit="L"><![CDATA[600]]></volume>', vol.to_xml
      vol.cdata = 660
      assert_equal '<volume unit="L"><![CDATA[660]]></volume>', vol.to_xml

      long_str = "_" * 1000000
      vol.content = long_str
      assert_equal '<volume unit="L">' + long_str + '</volume>', vol.to_xml

      vol.cdata = long_str
      assert_equal '<volume unit="L"><![CDATA[' + long_str + ']]></volume>', vol.to_xml

      vol.cdata = ""
      assert_equal '<volume unit="L"><![CDATA[]]></volume>', vol.to_xml

      # invalid stripping might occur
      long_str = "_" + ' ' * 1000000 + '_'
      vol.content = long_str
      assert_equal '<volume unit="L">' + long_str + '</volume>', vol.to_xml

      vol.content = nil
      assert_equal '<volume unit="L"></volume>', vol.to_xml

      cnt = 0
      result = OXM.from_xml(input.call, 'container/item/volume') do |obj|
        assert_equal 'volume', obj.tag
        assert obj.is_a?(OXM::Object)
        cnt += 1
      end
      assert_equal 8, cnt
      assert_nil result
    end
  end

  def test_nil
    str = <<-EOF
    <container>
      <item></item>
      <item>        </item>
      <item>
      </item>
      <item>

      </item>
    </container>
    EOF

    OXM.from_xml(str, 'container/item') do |item|
      assert_nil item.content
      assert_equal "<item></item>", item.to_xml
    end
  end

  def test_compaction
    str = <<-EOF
    <container attr1="1" attr2="2">
      <item dept="array">
        <volume unit="ml"><![CDATA[ 100 ]]></volume>
        <volume unit="ml"><![CDATA[200]]></volume>
      </item>

      <item dept="single">
        <volume unit="l">200</volume>
      </item>

      <item dept="single">
        <volume unit="ML"></volume>
      </item>

      <item dept="single">
        <volume unit="l">200</volume>
        <volume></volume>
      </item>

      <item dept="nil">
        <volume></volume>
        <volume></volume>
      </item>
      <item dept="nil">
        <volume><extra></extra></volume>
        <volume><extra>2</extra></volume>
        <volume></volume>
      </item>
    </container>
    EOF

    items = OXM.from_xml(str, 'container/item').to_a
    assert_equal 6, items.length

    items[0].compact!
    assert_equal Array, items[0].volume.class

    items[1].compact!
    assert_equal OXM::Object, items[1].volume.class

    items[2].compact!
    assert_equal OXM::Object, items[2].volume.class
    assert_equal nil, items[2].volume.content
    assert_equal 'ML', items[2].volume['unit']

    items[3].compact!
    assert_equal OXM::Object, items[3].volume.class
    assert_equal '<item dept="single"><volume unit="l">200</volume></item>', items[3].inspect
    assert_equal "200", items[3].volume.content

    items[4].compact!
    assert_equal nil, items[4].volume

    assert_raise(NoMethodError) {
      items[4].voll
    }

    items[5].compact!
    assert_equal Array, items[5].volume.class
    assert_equal 2, items[5].volume.length

  end
end
