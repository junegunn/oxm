require 'nokogiri'
require 'builder'
require 'oxm/sax_handler'
require 'oxm/enumerator'
require 'oxm/object'

module OXM
  # @param [IO/String] xml XML data
  # @param [String] loop_element
  # @return [OXM::Enumerator] Array of OXM::Objects
  def self.from_xml xml, loop_element, &block
    enumerator = OXM::Enumerator.new(xml, loop_element)
    if block_given?
      enumerator.each(&block)
    else
      enumerator
    end
  end
end
