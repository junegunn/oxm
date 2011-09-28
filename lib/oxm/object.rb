class OXM
  class Object
    attr_reader :tag

    # @return [String/NilClass]
    def content
      @data
    end

    # @param [String] val Text
    # @param [String] val
    # @return [String]
    def content= val
      @cdata = false
      @data = val
    end

    # @param [String] val CDATA content
    # @return [String]
    def cdata= val
      @cdata = true
      @data = val
    end

    # @return [Boolean]
    def cdata?
      @cdata
    end

    # @return [String] XML expression for this object
    def to_xml
      io = StringIO.new
      builder = Builder::XmlMarkup.new(:target => io)

      build_node = lambda do |node|
        builder.tag!(node.tag, node.attributes) do
          node.elements.each do |tag, elements|
            next if elements.nil?
            elements = [elements] unless elements.is_a? Array
            elements.each do |child|
              build_node.call child
            end
          end
          if node.content
            if node.cdata?
              builder.cdata! node.to_s
            else
              builder.text! node.to_s
            end
          end
        end
      end

      build_node.call self
      io.string
    end

    # @return [String]
    def to_s
      @data.to_s
    end

    # @return [String]
    def inspect
      to_xml
    end

    # @param [String] attr
    # @return [String]
    def [] attr
      @attrs[attr.to_s]
    end

    # @param [String] attr
    # @param [String] val
    # @return [String]
    def []= attr, val
      @attrs[attr.to_s] = val
    end

    # @return [Hash]
    def attributes
      @attrs
    end

    # @return [Hash]
    def elements
      @nodes
    end
    alias children elements

    # @param [String] tag
    # @param [OXM::Object] object
    # @return [OXM::Object]
    def add_node tag, object
      @nodes[tag] ||= []
      @nodes[tag] << object
      self
    end

    # Compacts the object by removing empty child elements and then collapsing element Arrays. 
    # After compaction, single-element arrays are collapsed, and empty arrays become nil.
    # @return [OXM::Object]
    def compact!
      @nodes.each do |key, value|
        if value.is_a?(Array)
          value = value.reject(&:empty?)
          @nodes[key] =
            case value.length
            when 0
              nil
            when 1
              value.first
            else
              value
            end
        end
      end
      self
    end

    # @param [String] tag
    # @param [Hash] attrs
    # @return [OXM::Object]
    def initialize tag, attrs = {}
      @tag = tag
      @attrs = attrs
      @nodes = {}
      @cdata = false
      @data  = nil
    end

    # @return [Boolean] Return if the element is empty (no text value, no attributes and no child elements)
    def empty?
      self.to_s.empty? && self.attributes.empty? && self.elements.empty?
    end

  private
    def method_missing(symb, *args)
      if @nodes.has_key?(symb.to_s)
        return @nodes[symb.to_s]
      else
        raise NoMethodError.new("undefined method or attribute `#{symb}'")
      end
    end
  end#Object
end#OXM

