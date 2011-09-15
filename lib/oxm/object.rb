module OXM
  class Object
    attr_reader :tag

    # @return [String]
    def cdata
      @text if @cdata
    end

    # @return [String]
    def text
      @text unless @cdata
    end

    # @param [String] val CDATA content
    # @return [String]
    def cdata= val
      @cdata = true
      process val
    end

    # @param [String] val Text
    # @param [String] val
    # @return [String]
    def text= val
      @cdata = false
      process val
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
        builder.tag!(node.tag, self.attributes) do
          node.elements.each do |tag, elements|
            elements.each do |child|
              build_node.call child
            end
          end
          if node.to_s
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
      @text
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

    # @return [OXM::Object]
    def compact!
      @nodes.each do |key, value|
        @nodes[key] = value.first if value.is_a?(Array) && value.length == 1
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
      @text  = nil
    end

  private
    def method_missing(symb, *args)
      if @nodes.has_key?(symb.to_s)
        return @nodes[symb.to_s]
      else
        raise NoMethodError.new("undefined method or attribute `#{symb}'")
      end
    end

    def process str
      str = str.to_s.strip
      return if str.empty?
      @text = str
    end

  end#Object
end#OXM

