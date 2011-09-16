module OXM
  class Enumerator
    include Enumerable

    def initialize xml, loop_element
      @xml = xml
      @loop_element = loop_element
    end

    def each &block
      handler = OXM::SaxHandler.new(@loop_element, &block)
      parser = Nokogiri::XML::SAX::Parser.new(handler)
      parser.parse @xml
      nil
    end
  end
end#OXM

