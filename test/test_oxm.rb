require 'helper'

class TestOxm < Test::Unit::TestCase
  def test_from_xml_string
    str = <<-EOF
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
      </item>
    </container>
    EOF

    require 'tempfile'
    tf = Tempfile.new('oxm')
    tf << str
    tf.flush

    [str, File.open(tf.path)].each do |input|
      result = OXM.from_xml(input, 'container')
      assert       result.is_a?(Array)
      assert_equal 1, result.length
      assert_equal nil, result.first.to_s
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
      assert       result.first.item.first.volume.all? { |i| i.cdata == i.to_s }
      assert       result.first.item.first.volume.all? { |i| i.text.nil? }
      assert       result.first.item.last.volume.all? { |i| i.cdata? == false }

      container = result.first
      assert container.compact!.equal?(container) # Object identity
      assert container.item.is_a?(Array)

      result = OXM.from_xml(str, 'container/item')
      assert_equal 4, result.length

      item = result.last
      item.compact!
      assert item.volume.is_a?(OXM::Object)
      assert_equal '500', item.volume.to_s
      assert_equal 'L', item.volume['unit']

      result = OXM.from_xml(str, 'container/item/volume')
      assert_equal 7, result.length
      assert_equal %w[100 200 200 300 300 400 500], result.map(&:to_s)
      assert_equal %w[ml ml l l l ml L], result.map { |e| e['unit'] }
      assert_equal result.map { |e| e['unit'] }, result.map { |e| e[:unit] }
      assert_equal '<volume unit="ml"><![CDATA[100]]></volume>', result.first.to_xml

      vol = result[-2]
      assert_equal '<volume unit="ml">400</volume>', vol.to_xml
      vol['unit'] = 'L'
      assert_equal '<volume unit="L">400</volume>', vol.to_xml
      vol.text = 500
      assert_equal '<volume unit="L">500</volume>', vol.to_xml
      vol.text = 550
      assert_equal '<volume unit="L">550</volume>', vol.to_xml
      vol.cdata = 600
      assert_equal '<volume unit="L"><![CDATA[600]]></volume>', vol.to_xml
      vol.cdata = 660
      assert_equal '<volume unit="L"><![CDATA[660]]></volume>', vol.to_xml

      longtext = "_" * 1000000
      vol.text = longtext
      assert_equal '<volume unit="L">' + longtext + '</volume>', vol.to_xml

      vol.cdata = longtext
      assert_equal '<volume unit="L"><![CDATA[' + longtext + ']]></volume>', vol.to_xml

      cnt = 0
      result = OXM.from_xml(str, 'container/item/volume') do |obj|
        assert_equal 'volume', obj.tag
        assert obj.is_a?(OXM::Object)
        cnt += 1
      end
      assert_equal 7, cnt
      assert_nil result
    end
  end
end
