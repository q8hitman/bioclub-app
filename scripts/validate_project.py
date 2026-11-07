"""Portable structural checks. Does NOT compile Swift or execute XCTest."""
from pathlib import Path
import plistlib
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
project = (root / 'BSCKU.xcodeproj/project.pbxproj').read_text(encoding='utf-8-sig')
ids = re.findall(r'^([A-F0-9]{24}) =', project, re.M)
assert len(ids) == len(set(ids)), 'Duplicate project identifiers'
for ref in re.findall(r'\b[A-F0-9]{24}\b', project):
    assert ref in ids, f'Dangling reference {ref}'
for path in root.rglob('*.swift'):
    rel = path.relative_to(root).as_posix()
    assert f'path = "{rel}"' in project, f'Unregistered Swift file: {rel}'
for path in [root/'App/Info.plist', root/'App/PrivacyInfo.xcprivacy']:
    plistlib.loads(path.read_bytes())
ET.parse(root/'BSCKU.xcodeproj/xcshareddata/xcschemes/BSCKU.xcscheme')
assert 'NSAllowsArbitraryLoads' not in (root/'App/Info.plist').read_text()
assert 'SWIFT_VERSION = "6.0"' in project
print(f'PASS: {len(ids)} unique/resolved project objects; Swift membership; plist/scheme XML; ATS default; Swift 6 setting.')
print('NOT RUN: Swift compilation, XCTest, simulator, accessibility, performance, signing.')
