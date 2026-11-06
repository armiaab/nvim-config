import re
import sys

aff_in, dic_in, en_in, out = sys.argv[1:5]

aff = open(aff_in, encoding="latin-1").read()
used = set(re.findall(r"^(?:SFX|PFX) (\S+) ", aff, re.M))
for f in ("zc", "zi", "zD", "zN"):
    assert f not in used, f

clitics = ["nya", "ku", "mu", "lah", "kah", "pun", "nyalah", "nyakah", "nyapun", "kulah", "mulah", "kupun", "mupun"]

clitic_classes = {"o0", "nl", "n0", "l0"}
short_clitics = ["nya", "ku", "mu", "lah", "kah", "nyalah", "nyakah"]
src_lines = aff.split("\n")
new_lines, i, n_added = [], 0, 0
header = re.compile(r"^SFX (\S+) ([YN]) (\d+)(.*)$")
while i < len(src_lines):
    m = header.match(src_lines[i])
    if not m:
        new_lines.append(src_lines[i]); i += 1; continue
    cls, comb, count, rest = m.group(1), m.group(2), int(m.group(3)), m.group(4)
    rules = src_lines[i + 1:i + 1 + count]
    out_rules = []
    for r in rules:
        out_rules.append(r)
        parts = r.split()
        if len(parts) < 4 or parts[0] != "SFX":
            continue
        add, _, fl = parts[3].partition("/")
        if not re.search(r"(an|kan|i)$", add):
            continue
        fl_pairs = [fl[j:j + 2] for j in range(0, len(fl), 2)]
        keep = "".join(p for p in fl_pairs if p not in clitic_classes)
        for c in short_clitics:
            out_rules.append(f"SFX {cls} {parts[2]} {add}{c}{'/' + keep if keep else ''} {' '.join(parts[4:]) or '.'}")
            n_added += 1
    new_lines.append(f"SFX {cls} {comb} {len(out_rules)}{rest}")
    new_lines += out_rules
    i += 1 + count
aff = "\n".join(new_lines)
print(f"clitic variants added to suffix rules: {n_added}")
extra = [""]
extra.append(f"SFX zc Y {len(clitics)}")
extra += [f"SFX zc 0 {c} ." for c in clitics]
extra += ["", "SFX zi Y 2", "SFX zi 0 in .", "SFX zi 0 innya .", ""]
extra += ["PFX zD Y 1", "PFX zD 0 di .", "", "PFX zN Y 1", "PFX zN 0 nge .", ""]
open(f"{out}/idmix.aff", "w", encoding="latin-1", newline="\n").write(aff.rstrip("\n") + "\n" + "\n".join(extra))

lines = open(dic_in, encoding="latin-1").read().splitlines()
entries = {}
order = []
for line in lines[1:]:
    line = line.strip()
    if not line:
        continue
    word, _, flags = line.partition("/")
    flags = flags.split()[0] if flags else ""
    if word in entries:
        entries[word] += flags
    else:
        entries[word] = flags
        order.append(word)

def add_flags(word, new):
    have = entries.get(word)
    if have is None:
        entries[word] = ""
        order.append(word)
        have = ""
    pairs = {have[i:i + 2] for i in range(0, len(have), 2)}
    for f in new:
        if f not in pairs:
            have += f
            pairs.add(f)
    entries[word] = have

id_stems = list(order)
for w in id_stems:
    add_flags(w, ["zc", "zi"] if w.isalpha() and w.islower() else ["zc"])

stop = set("the and for but not you are was his her its our any all can has had one two out who why how may did get got let him she they them this that than then with from into onto upon were been have will shall would could should what when where which while very just also only such some more most much many each both".split())
n_en = 0
for raw in open(en_in, encoding="utf-8"):
    w = raw.strip().split("/")[0]
    if not re.fullmatch(r"[a-z]{3,}", w) or w in stop:
        continue
    add_flags(w, ["zc", "zD", "zN"])
    n_en += 1

with open(f"{out}/idmix.dic", "w", encoding="latin-1", newline="\n") as f:
    f.write(f"{len(order)}\n")
    for w in order:
        fl = entries[w]
        f.write(f"{w}/{fl}\n" if fl else f"{w}\n")
print(f"indonesian stems {len(id_stems)}, english words added {n_en}, total entries {len(order)}")
