"""Focused regression tests: inlined imports have no module alias to export.

These tests validate the Python source transformation. Mac host Nim compilation
of the real chaemon_header is a separate gate.
"""
import importlib.util
from pathlib import Path
import tempfile
import unittest

TOOL = Path(__file__).resolve().parents[1] / 'expander.py'
spec = importlib.util.spec_from_file_location('nacl_flattened_expander', TOOL)
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)


class FlattenedExports(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='nacl export ')
        self.root = Path(self.tmp.name)
        self.folder = self.root / 'atcoder'
        self.folder.mkdir()
        (self.folder / 'unit.nim').write_text('proc answer*(): int = 42\n', encoding='utf-8')
        self.bridge = self.folder / 'bridge.nim'
        self.bridge.write_text('''when not declared(NACL_BRIDGE):
  const NACL_BRIDGE* = true
  import atcoder/unit
  import std/strutils
  export unit, strutils
''', encoding='utf-8')
        self.main = self.root / 'main.nim'
        self.main.write_text('import atcoder/bridge\necho answer()\n', encoding='utf-8')

    def tearDown(self):
        self.tmp.cleanup()

    def expand(self, mode):
        ex.SOURCE_BYTES.clear()
        ex.BUNDLE_BYTES.clear()
        ex.EMBED_TEXTS.clear()
        return '\n'.join(ex.read_source(str(self.main), '', set(), self.root,
                                        self.root, None, mode, 0))

    def test_plain_elides_only_inlined_name(self):
        actual = self.expand('plain')
        self.assertIn('proc answer*()', actual)
        self.assertIn('  export strutils', actual)
        self.assertNotIn('export unit', actual)
        self.assertIn('import std/strutils', actual)

    def test_embed_inner_source_drops_stale_alias(self):
        self.expand('embed')
        content = ex.EMBED_TEXTS['atcoder/bridge.nim']
        self.assertIn('export strutils', content)
        self.assertNotIn('export unit', content)

    def test_bundle_keeps_original_module_bytes(self):
        self.expand('bundle')
        self.assertEqual(ex.BUNDLE_BYTES['atcoder/bridge.nim'],
                         self.bridge.read_bytes())
        self.assertIn(b'export unit, strutils', ex.BUNDLE_BYTES['atcoder/bridge.nim'])

    def test_unrelated_export_left_alone(self):
        self.bridge.write_text('export unrelated\n', encoding='utf-8')
        self.assertIn('export unrelated', self.expand('plain'))

    def test_multiple_inlined_names_elided(self):
        self.bridge.write_text('''import atcoder/unit
include atcoder/unit
export unit
''', encoding='utf-8')
        self.assertNotIn('export unit', self.expand('plain'))

    def test_nested_unguarded_module_keeps_module_level_indentation(self):
        actual = self.expand('plain')
        # unit has no `when` guard. Its trailing statement must be aligned
        # with its procedure, rather than introduce an invalid new indent.
        self.assertIn('  proc answer*(): int = 42\n  discard\n', actual)

    def test_embed_nested_unguarded_module_keeps_indentation(self):
        self.expand('embed')
        actual = ex.EMBED_TEXTS['atcoder/bridge.nim']
        self.assertIn('  proc answer*(): int = 42\n  discard\n', actual)


if __name__ == '__main__':
    unittest.main(verbosity=2)
