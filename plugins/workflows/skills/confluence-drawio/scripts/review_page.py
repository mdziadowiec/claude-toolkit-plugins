"""Shows what a drafted page changes: a text diff of original vs fixed ADF, plus safety checks.

Usage: python review_page.py <original.json> <fixed.json>
Checks: JSON parses, inline-comment annotation marks kept (by id), extension nodes unchanged.
"""
import difflib
import json
import sys



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


def lines(n, out, depth=0):
    t = n.get('type')
    c = n.get('content') or []
    if t == 'heading':
        out.append('#' * n['attrs']['level'] + ' ' + inline(c))
    elif t == 'paragraph':
        s = inline(c)
        if s.strip():
            out.append('  ' * depth + s)
    elif t == 'codeBlock':
        out.append('```' + (n.get('attrs') or {}).get('language', ''))
        out.extend(inline(c).split('\n'))
        out.append('```')
    elif t in ('bulletList', 'orderedList'):
        for i, li in enumerate(c, 1):
            sub = []
            for ch in li.get('content', []):
                lines(ch, sub, depth + 1)
            out.append('  ' * depth + (f'{i}.' if t == 'orderedList' else '-') + ' ' + ' '.join(s.strip() for s in sub))
    elif t == 'table':
        for row in c:
            cells = []
            for cell in row.get('content', []):
                sub = []
                for ch in cell.get('content', []):
                    lines(ch, sub)
                cells.append(' '.join(s.strip() for s in sub))
            out.append('| ' + ' | '.join(cells) + ' |')
    elif t == 'extension':
        p = n['attrs'].get('parameters', {}).get('macroParams', {})
        out.append('[macro ' + n['attrs'].get('extensionKey', '?') + ' ' + p.get('diagramName', {}).get('value', '') + ']')
    else:
        for ch in c:
            lines(ch, out, depth)


def collect(n, kind, acc):
    if isinstance(n, dict):
        if kind == 'annotation':
            for m in n.get('marks', []) if n.get('type') == 'text' else []:
                if m.get('type') == 'annotation':
                    acc.append((m['attrs']['id'], n.get('text', '')))
        elif n.get('type') == 'extension':
            acc.append(json.dumps(n, sort_keys=True))
        for v in n.values():
            collect(v, kind, acc)
    elif isinstance(n, list):
        for v in n:
            collect(v, kind, acc)


orig = json.load(open(sys.argv[1], encoding='utf-8-sig'))
fixed = json.load(open(sys.argv[2], encoding='utf-8-sig'))
a, b = [], []
lines(orig, a)
lines(fixed, b)
for line in difflib.unified_diff(a, b, 'published', 'draft', n=0, lineterm=''):
    print(line)

ann_a, ann_b = [], []
collect(orig, 'annotation', ann_a)
collect(fixed, 'annotation', ann_b)
ext_a, ext_b = [], []
collect(orig, 'extension', ext_a)
collect(fixed, 'extension', ext_b)
print('\n== checks')
print('inline comments kept:', {i for i, _ in ann_a} <= {i for i, _ in ann_b}, f'({len(ann_a)} -> {len(ann_b)})')
for i, t in ann_a:
    if i not in {x for x, _ in ann_b}:
        print('  LOST comment', i, 'on', repr(t))
print('macros unchanged:', ext_a == ext_b, f'({len(ext_a)} -> {len(ext_b)})')
