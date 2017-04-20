import sys
import xml.etree.ElementTree as ET

# This program should be run like:
# python2 clean_up_process_with_id.py $id
args = sys.argv
id = '-' + args[1] + '-'

root = ET.parse('/etc/guacamole/noauth-config.xml').getroot()

for child in root:
    if id in child.attrib['name']:
        root.remove(child)
        break
tree = ET.ElementTree(root)
tree.write('/etc/guacamole/noauth-config.xml')
