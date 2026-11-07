"""Optional grammar check, not Swift type checking. pip install tree-sitter tree-sitter-swift."""
from pathlib import Path
from tree_sitter import Language, Parser
import tree_sitter_swift

root = Path(__file__).resolve().parents[1]
parser = Parser(Language(tree_sitter_swift.language()))
paths = list(root.rglob('*.swift'))
failures = []
for path in paths:
    tree = parser.parse(path.read_bytes())
    if tree.root_node.has_error:
        failures.append(str(path.relative_to(root)))
if failures:
    raise SystemExit('Syntax errors: ' + ', '.join(failures))
print(f'PASS: parsed {len(paths)} Swift files. No type checking or Apple SDK validation performed.')
