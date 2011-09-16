# oxm

A tiny, easy-to-use Object-XML-Mapper for Ruby. 
Internally uses Nokogiri SAX parser which allows handling of large XML documents.

## Installation

```
gem install oxm
```

## Examples

```xml
<orders>
  <order date="2011/08/27">
    <item amount="5">Apple</item>
    <item amount="2">Banana</item>
    <customer id="100">Alice</customer>
  </order>
  <order date="2011/08/27">
    <item amount="1">Zoltax</item>
    <customer id="200">Bob</customer>
  </order>
</orders>
```

```ruby
require 'oxm'

# With block
OXM.from_xml(xml_data_or_io, 'orders/order') do |order|
  # Accessing attributes of the element
  order['date']
  order.attributes

  # Accessing attributes and text/cdata values of child elements
  order.item.first['amount']
  order.item.first.to_s
  order.item.first.cdata?

  # Traverses child elements
  order.elements.each do |tag, elements_for_the_tag|
    # ...
  end


  # Compaction: collapse single-element Arrays
  order.customer.first.to_s
  order.customer.first['id']
  order.compact!
  order.customer.to_s
  order.customer['id']

  # XML expression for the element
  order.to_xml
  order.item.first.to_xml
end

# Array of elements are returned when block is not given
items = OXM.from_xml(xml_data_or_io, 'orders/order/item')
```

## TODO
* When block is not given, make from_xml return an Enumerator instead of an Array

## Contributing to oxm
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Junegunn Choi. See LICENSE.txt for
further details.

