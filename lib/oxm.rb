require 'nokogiri'
require 'builder'
require 'oxm/sax_handler'
require 'oxm/object'

class OXM
  # @param [IO/String] xml XML data
  # @param [String] loop_element
  # @return [Array] Array of OXM::Objects
  def self.from_xml xml, loop_element, &block
    oxm = OXM.new xml
    oxm.from_xml loop_element, &block
  end

  # @param [IO/String] xml XML data
  def initialize xml
    @xml = xml
  end

  # @param [String] loop_element
  def from_xml loop_element, &block
    @handler = OXM::SaxHandler.new(loop_element, &block)
    parser = Nokogiri::XML::SAX::Parser.new(@handler)
    parser.parse @xml
    @handler.outputs unless block_given?
  end

  # @return [Array] Error messages during the last from_xml call
  def errors
    @handler ? @handler.errors : []
  end

  # @return [Array] Warning messages during the last from_xml call
  def warnings
    @handler ? @handler.warnings : []
  end
end

