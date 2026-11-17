"""Turns each audited Confluence page (ADF JSON) plus its draw.io diagrams into one readable text file.

Usage: python adf_to_text.py <audit dir>
Writes <audit dir>/text/<page id>.md. Diagram labels follow each diagram block as an indented list.
"""
import glob
import html
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

audit_dir = sys.argv[1]
os.makedirs(os.path.join(audit_dir, 'text'), exist_ok=True)


def inline(nodes):
    out = []
    for n in nodes or []:
        if n.get('type') == 'text':
            t = n.get('text', '')
            if any(m.get('type') == 'code' for m in n.get('marks', [])):
                t = '`' + t + '`'
            out.append(t)
        elif n.get('type') == 'hardBreak':
            out.append(' / ')
        else:
            out.append(inline(n.get('content')))
    return ''.join(out)


def diagram_labels(pid, name):
    path = os.path.join(audit_dir, 'drawio', pid + '-' + re.sub(r'[^\w.-]', '_', name))
    if not os.path.exists(path):
        return ['    (diagram file not found: ' + name + ')']
    lines = []
    for c in ET.parse(path).getroot().iter('mxCell'):
        v = c.get('value')
        if v:
            plain = re.sub(r'<br\s*/?>|<hr[^>]*>', ' | ', html.unescape(v))
            plain = html.unescape(re.sub(r'<[^>]+>', '', plain))
            kind = 'arrow' if c.get('edge') else 'box'
            lines.append(f'    - {kind}: {plain.strip()}')
    return lines


def block(n, pid, out, depth=0):
    t = n.get('type')
    c = n.get('content') or []
    if t == 'heading':
        out.append('\n' + '#' * n['attrs']['level'] + ' ' + inline(c))
    elif t == 'paragraph':
        s = inline(c)
        if s.strip():
            out.append('  ' * depth + s)
    elif t in ('bulletList', 'orderedList'):
        for i, li in enumerate(c, 1):
            mark = f'{i}.' if t == 'orderedList' else '-'
            sub = []
            for ch in li.get('content', []):
                block(ch, pid, sub, depth + 1)
            out.append('  ' * depth + mark + ' ' + ' '.join(s.strip() for s in sub))
    elif t == 'table':
        for row in c:
            cells = [' '.join(inline(p.get('content')) for p in cell.get('content', [])) for cell in row.get('content', [])]
            out.append('| ' + ' | '.join(cells) + ' |')
    elif t == 'extension':
        p = n['attrs'].get('parameters', {}).get('macroParams', {})
        name = p.get('diagramName', {}).get('value')
        if name:
            out.append(f'[draw.io diagram {name}]')
            out.extend(diagram_labels(pid, name))
        else:
            out.append('[macro ' + n['attrs'].get('extensionKey', '?') + ']')
    else:
        for ch in c:
            block(ch, pid, out, depth)


for f in sorted(g for g in glob.glob(os.path.join(audit_dir, 'page-*.json')) if not g.endswith('.meta.json')):
    pid = os.path.basename(f)[5:-5]
    out = []
    block(json.load(open(f, encoding='utf-8-sig')), pid, out)
    with open(os.path.join(audit_dir, 'text', pid + '.md'), 'w', encoding='utf-8') as o:
        o.write('\n'.join(out))
    print(pid, len(out), 'lines')
