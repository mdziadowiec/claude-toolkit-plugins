"""Collects code-style names from the Confluence pages and draw.io diagrams and lists the ones the code no longer contains.

Usage: python audit_names.py <audit dir> <names file out>
Writes one line per (name, page id, source) to the out file; the caller checks the names against the repo.
"""
import glob
import html
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

audit_dir, out_file = sys.argv[1], sys.argv[2]
NAME = re.compile(r'\b(?:[A-Z][a-z0-9]+[A-Z][A-Za-z0-9]*|I[A-Z][a-z]+[A-Za-z0-9]*|[a-z]+[A-Z][A-Za-z0-9]*)\b')


def walk(node, in_code, found):
    if isinstance(node, dict):
        if node.get('type') == 'text':
            code = any(m.get('type') == 'code' for m in node.get('marks', []))
            found.append((node.get('text', ''), code))
        if node.get('type') == 'extension':
            p = node.get('attrs', {}).get('parameters', {}).get('macroParams', {})
            found.append(('@@drawio ' + p.get('diagramName', {}).get('value', '') + ' r' + p.get('revision', {}).get('value', ''), False))
        for v in node.values():
            walk(v, in_code, found)
    elif isinstance(node, list):
        for v in node:
            walk(v, in_code, found)


rows = set()
macros = {}
for f in sorted(g for g in glob.glob(os.path.join(audit_dir, 'page-*.json')) if not g.endswith('.meta.json')):
    pid = os.path.basename(f)[5:-5]
    found = []
    walk(json.load(open(f, encoding='utf-8-sig')), False, found)
    for text, code in found:
        if text.startswith('@@drawio '):
            macros.setdefault(pid, []).append(text[9:])
            continue
        for n in NAME.findall(text):
            rows.add((n, pid, 'code' if code else 'text'))

for f in glob.glob(os.path.join(audit_dir, 'drawio', '*.drawio')):
    base = os.path.basename(f)
    pid = base.split('-', 1)[0]
    for c in ET.parse(f).getroot().iter('mxCell'):
        v = c.get('value') or ''
        plain = re.sub(r'<[^>]+>', ' ', html.unescape(html.unescape(v)))
        for n in NAME.findall(plain):
            rows.add((n, pid, 'diagram:' + base.split('-', 1)[1][-20:-7]))

with open(out_file, 'w', encoding='utf-8') as o:
    for r in sorted(rows):
        o.write('\t'.join(r) + '\n')
print('names:', len({r[0] for r in rows}), 'rows:', len(rows))
for pid, ms in macros.items():
    print('macros', pid, ms)
