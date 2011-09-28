class OXM
  class SaxHandler < Nokogiri::XML::SAX::Document
    attr_reader :outputs
    attr_reader :warnings
    attr_reader :errors

    def initialize loop_node, &block
      @loop_node = loop_node
      @block = block
      @tags = []
      @objects = []
      @outputs = []

      @warnings = []
      @errors = []
    end

    def warning str
      @warnings << str
    end

    def error str
      @errors << str
    end

    def start_element tag, attributes
      @tags << tag

      # Met loop element
      if @objects.empty?
        if match?
          @objects << @object = OXM::Object.new(tag, Hash[*attributes.flatten])
        end
      elsif @object
        @object.add_node tag, node_obj = OXM::Object.new(tag, Hash[*attributes.flatten])
        @objects << @object = node_obj
      end
    end

    def cdata_block str
      @object.cdata = @object.to_s + str if @object
    end

    def characters str
      @object.content = @object.to_s + str if @object
    end

    def end_element tag
      unless @objects.empty?
        obj = @objects.pop

        # Strip content
        if obj.cdata?
          obj.cdata = obj.to_s.strip
        else
          obj.content = obj.to_s.strip
        end
        obj.content = nil if obj.to_s.empty?

        if match?
          if @block
            @block.call obj
          else
            @outputs << obj
          end
          @object = nil
        else
          @object = @objects.last
        end
      end
      @tags.pop
    end

    def match?
      @tags.join('/') == @loop_node
    end
  end
end#OXM
