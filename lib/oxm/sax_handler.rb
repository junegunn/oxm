module OXM
  class SaxHandler < Nokogiri::XML::SAX::Document
    attr_reader :outputs

    def initialize loop_node, &block
      @loop_node = loop_node
      @block = block
      @tags = []
      @objects = []
      @outputs = []
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
      @object.cdata = @object.cdata.to_s + str if @object
    end

    def characters str
      @object.text = @object.text.to_s + str if @object
    end

    def end_element tag
      unless @objects.empty?
        if match?
          obj = @objects.pop
          if @block
            @block.call obj
          else
            @outputs << obj
          end
          @object = nil
        else
          @objects.pop
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
