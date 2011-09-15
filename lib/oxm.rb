require 'nokogiri'
require 'builder'
require 'oxm/sax_handler'
require 'oxm/object'

module OXM
  # @param [IO/String] xml XML data
  # @param [String] loop_element
  # @return [Array] Array of OXM::Objects
  def self.from_xml xml, loop_element, &block
    handler = OXM::SaxHandler.new(loop_element, &block)
    parser = Nokogiri::XML::SAX::Parser.new(handler)
    parser.parse xml
    handler.outputs unless block_given?
  end
end
