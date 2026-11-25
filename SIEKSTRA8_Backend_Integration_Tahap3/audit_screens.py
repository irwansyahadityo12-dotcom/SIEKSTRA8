import os, re

BASE = r'c:\SIEKSTRA8_Backend_Integration_Tahap3\SIEKSTRA8_Backend_Integration_Tahap3\lib'
DIRS = ['admin/screens', 'siswa/screens']

DUMMY_PATTERNS = [
    (r'//\s*(dummy|hardcode|static data|TODO|FIXME|mock|placeholder|sementara|statis|belum terhubung)', 'Comment: dummy/todo/mock'),
    (r'onPressed\s*:\s*\(\)\s*\{\s*\}', 'Empty onPressed callback'),
    (r'onTap\s*:\s*\(\)\s*\{\s*\}', 'Empty onTap callback'),
    (r'onPressed\s*:\s*null', 'Button disabled (null)'),
    (r'final\s+_\w*(List|Items|Data|Events|Rows|Notifications|Records|History)\s*=\s*\[', 'Hardcoded list field'),
    (r'final\s+List<[^>]+>\s+_\w+\s*=\s*\[', 'Hardcoded typed list'),
    (r"'(TODO|coming soon|segera hadir|belum tersedia|fitur ini)'", 'Placeholder string'),
    (r'SnackBar.*content.*Text.*TODO', 'SnackBar with TODO'),
    (r"ScaffoldMessenger.*'(TODO|Belum|Coming|Segera)'", 'SnackBar placeholder'),
]

REPO_CONNECTED = r'_repo\.|_repository\.|SiekstraRepository'

results = {}

for d in DIRS:
    folder = os.path.join(BASE, d.replace('/', os.sep))
    for fn in sorted(os.listdir(folder)):
        if not fn.endswith('.dart'):
            continue
        path = os.path.join(folder, fn)
        txt = open(path, encoding='utf-8', errors='replace').read()
        lines = txt.split('\n')

        issues = []
        seen_lines = set()

        for pat, label in DUMMY_PATTERNS:
            for m in re.finditer(pat, txt, re.IGNORECASE):
                ln = txt[:m.start()].count('\n') + 1
                if ln not in seen_lines:
                    seen_lines.add(ln)
                    snippet = lines[ln-1].strip()[:90]
                    issues.append((ln, label, snippet))

        has_repo = bool(re.search(REPO_CONNECTED, txt))
        has_supabase_direct = bool(re.search(r'Supabase\.instance|supabase\.from\b', txt))

        issues.sort()
        results[d + '/' + fn] = {
            'issues': issues,
            'has_repo': has_repo,
            'has_supabase_direct': has_supabase_direct,
            'lines': len(lines),
        }

for key, val in results.items():
    folder = key.split('/')[0]
    fname = key.split('/')[-1]
    has_issues = bool(val['issues'])
    no_repo = not val['has_repo']

    if no_repo and has_issues:
        marker = 'CRITICAL'
    elif no_repo:
        marker = 'NO_REPO'
    elif has_issues:
        marker = 'ISSUES'
    else:
        marker = 'OK'

    print(marker + ' [' + folder + '] ' + fname + ' (' + str(val['lines']) + ' baris) repo=' + str(val['has_repo']) + ' direct_sb=' + str(val['has_supabase_direct']))
    for ln, label, snippet in val['issues']:
        print('  L' + str(ln) + ': [' + label + '] ' + snippet)

