### 0.1.3 / 2011/09/27
* OXM can be instantiated. Warning and error messages during the last OXM#from_xml call can be accessed with OXM#warnings and OXM#errors instance methods.

### 0.1.2 / 2011/09/20
* Bug fix: Invalid handling of empty content

### 0.1.1 / 2011/09/19
* Bug fix: OXM::Object#compact! incorrectly nilified elements
### 0.1.0 / 2011/09/19
* Disclaimer: Not compatible to the previous versions
 * Removed: OXM::Object#cdata, OXM::Object#text, OXM::Object#text=
 * Added: OXM::Object#content, OXM::Object#content=
 * Changed: OXM::Object#to_s never returns nil
 * Changed: OXM::Object#compact! removes empty elements as well (no text value, no attributes at all)
 * Fix: Allows assignment of nil/empty string as element values

### 0.0.2 / 2011/09/15
* OXM::Object#compact! added
* OXM::Object#elements as an alias of OXM::Object#children

### 0.0.1 / 2011/09/15
* Initial release

