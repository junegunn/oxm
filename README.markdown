# oxm

A tiny Object-XML-Mapper. Requires Nokogiri SAX parser.

## Examples
```xml
<orders>
  <order date="2011/08/27">
    <item amount="5">Apple</item>
    <item amount="2">Banana</item>
  </order>
  <order date="2011/08/27">
    <item amount="1">Zoltax</item>
  </order>
</orders>
```

```ruby
require 'oxm'

# With block
OXM.from_xml(xml_data_or_io, 'orders/order') do |order|
  order['date']
  order.item.first['amount']
  order.item.first.to_s
  order.item.first.cdata?

  order.children.each do |tag, children|
    # ...
  end

  order.to_xml
  order.item.first.to_xml
end

# Without block
items = OXM.from_xml(xml_data_or_io, 'orders/order/item')
```

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

