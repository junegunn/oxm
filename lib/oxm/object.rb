module OXM
  class Object
    attr_reader :tag

    def cdata
      @text if @cdata
    end

    def text
      @text unless @cdata
    end

    def cdata= val
      @cdata = true
      process val
    end

    def text= val
      @cdata = false
      process val
    end

    def cdata?
      @cdata
    end

    def to_xml
      io = StringIO.new
      builder = Builder::XmlMarkup.new(:target => io)

      build_node = lambda do |node|
        builder.tag!(node.tag, self.attributes) do
          node.children.each do |tag, children|
            children.each do |child|
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

    def to_s
      @text
    end

    def inspect
      to_xml
    end

    def [] attr
      @attrs[attr.to_s]
    end

    def []= attr, val
      @attrs[attr.to_s] = val
    end

    def attributes
      @attrs
    end

    def children
      @nodes
    end

    def add_node tag, object
      @nodes[tag] ||= []
      @nodes[tag] << object
    end

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

