require 'nokogiri'
require 'builder'
require 'oxm/sax_handler'
require 'oxm/object'

module OXM
  def self.from_xml xml, loop_node, &block
    handler = OXM::SaxHandler.new(loop_node, &block)
    parser = Nokogiri::XML::SAX::Parser.new(handler)
    parser.parse xml
    handler.outputs unless block_given?
  end
end
