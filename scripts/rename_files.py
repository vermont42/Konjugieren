#!/usr/bin/env python3
"""Rename or move files and directories, and repair every reference to them.

Consumes:  a JSON file mapping old repo-relative path -> new repo-relative path, and the
           tracked text files of the repo it is run in.
Produces:  the renames (`git mv` for tracked paths, a plain rename for untracked ones) and
           rewritten references. Without --apply it only reports what it would do.
Run:       from the ROOT of the repo being changed, which need not be this one:

    python3 scripts/rename_files.py moves.json                 # dry run
    python3 scripts/rename_files.py moves.json --verbose       # dry run, one line per file
    python3 scripts/rename_files.py moves.json --apply
    python3 ../Konjugieren/scripts/rename_files.py moves.json  # from Conjugar or Conjuguer

Options:   --links-only PATH   rewrite only Markdown link targets in PATH (repeatable).
                               Defaults to docs/blog_notes.md when that file exists.
           --exclude PATH      do not touch PATH at all (repeatable).

Why this exists
---------------
Written on 2026-11-16, when Konjugieren's prompts, plans, and documents were sorted into the
right folders and renamed to snake_case: 300 renames and a thousand references. Each rule
below is here because the obvious find-and-replace got that case wrong.

What it rewrites
----------------
All three rules are computed against the tree as it is BEFORE anything moves.

1. Markdown link targets. Each [text](target) is resolved against the containing file's old
   folder, mapped through the moves, and re-derived relative to the containing file's new
   folder. One rule therefore repairs links TO a moved file and the moved file's OWN links,
   which change meaning the moment the file sits in a different folder.
2. Written-out paths, `plans/sweep-comments.md`, in prose, comments, and code.
3. Bare basenames, `sweep-comments.md`. These survive a change of folder and go stale only
   when the NAME changes, which is why a move-only pass never needs this rule and a rename
   always does.

Rules 2 and 3 share one regex. It captures whatever path-like text precedes the basename, and
that prefix decides the case:

- empty: a bare mention. Rewritten when the basename changes.
- an allowed lead plus the file's own folder: a written-out path. Rewritten in full. Allowed
  leads are nothing, `./`, a run of `../`, and anything ending in this repo's folder name
  (`~/Desktop/workspace/Konjugieren/`).
- a tail of the file's own folder (`style/xc-fixes.json` for a file in `verbdata/style/`):
  a path relative to somewhere inside the repo. The basename is rewritten if the folder did
  not change. If it did, the mention is reported for a human, since the right relative path
  depends on where the reader is standing.
- anything else: a DIFFERENT file, and it is skipped and reported. The real case was
  `Conjugar.mig/prompts/sweep-comments.md`, the same filename in a sibling repo. A GitHub URL
  lands here too, deliberately: the skip report is how an inbound link gets noticed.

A directory's name is rewritten only as a path segment, where it touches a slash. In
"the gloss-review driver" the same letters are an English compound and are left alone.

What it cannot see
------------------
- A name built at runtime. `"%s-round%d.json" % (name, n)` matches no filename. Search the
  scripts for the stem and fix those by hand.
- A sibling repo's file that happens to share a path, as in "Conjugar's `docs/pdf.md`". The
  prefix `docs/` looks like this repo's own. Review changed lines that mention another repo.
- Links from OUTSIDE the repo: a published blog post, a sent email, the shipped app. Search
  for those before renaming. See CLAUDE.md § File Naming for the recipe.
- The contents of untracked files. An untracked file can be renamed (list it in the moves),
  but only tracked text files are searched for references.

Limits
------
A file inside a directory that is itself being moved cannot be renamed in the same run. Do the
files first, then the directory, as two runs.
"""
import json
import os
import re
import subprocess
import sys

# Same shape as check_docs.py's LINK_RE, so what this repairs is what that checks.
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)#\s]+)(?:#[^)]*)?\)")


def parse_args(argv):
    args = {"apply": False, "verbose": False, "links_only": [], "exclude": [], "moves": None}
    it = iter(argv)
    for a in it:
        if a == "--apply":
            args["apply"] = True
        elif a == "--verbose":
            args["verbose"] = True
        elif a == "--links-only":
            args["links_only"].append(os.path.normpath(next(it)))
        elif a == "--exclude":
            args["exclude"].append(os.path.normpath(next(it)))
        elif a.startswith("--"):
            sys.exit(f"unknown option {a}")
        else:
            args["moves"] = a
    if not args["moves"]:
        sys.exit(__doc__.split("\n\n")[1])
    return args


def git(*cmd):
    return subprocess.run(["git", *cmd], capture_output=True, text=True, check=True).stdout


def main():
    args = parse_args(sys.argv[1:])
    top = git("rev-parse", "--show-toplevel").strip()
    if os.path.realpath(top) != os.path.realpath(os.getcwd()):
        sys.exit(f"run this from the repo root, {top}")
    repo_name = os.path.basename(top)
    moves = {os.path.normpath(k): os.path.normpath(v) for k, v in json.load(open(args["moves"])).items()}
    moves = {k: v for k, v in moves.items() if k != v}
    links_only = set(args["links_only"])
    if not links_only and os.path.isfile("docs/blog_notes.md"):
        links_only = {"docs/blog_notes.md"}
    excluded = set(args["exclude"])

    tracked = git("ls-files").splitlines()
    tracked_set = set(tracked)
    dir_moves = {o: n for o, n in moves.items() if os.path.isdir(o)}
    file_moves = {o: n for o, n in moves.items() if o not in dir_moves}

    # ---- sanity checks, all before anything is touched ----
    problems = []
    for old, new in moves.items():
        if not os.path.exists(old):
            problems.append(f"missing: {old}")
        # On a case-insensitive filesystem a case-only rename "exists" at its own destination.
        if os.path.exists(new) and old.lower() != new.lower():
            problems.append(f"would overwrite: {new}")
    if len(set(moves.values())) != len(moves):
        problems.append("two entries land on the same new path")
    for old in file_moves:
        for d in dir_moves:
            if old.startswith(d + "/"):
                problems.append(f"{old} is inside {d}, which also moves: use two runs")
    if problems:
        sys.exit("\n".join(problems))

    def moved(path):
        """Where a repo-relative path ends up. Unmoved paths map to themselves."""
        if path in file_moves:
            return file_moves[path]
        for old, new in dir_moves.items():
            if path == old or path.startswith(old + "/"):
                return new + path[len(old):]
        return path

    # ---- the name table for rules 2 and 3 ----
    # A basename may belong to several entries (two folders can each hold a `triage.md`).
    by_name = {}
    for old, new in moves.items():
        by_name.setdefault(os.path.basename(old), []).append((old, new, old in dir_moves))
    name_re = re.compile(
        r"(?P<prefix>[\w~./\-]*?)(?P<name>"
        # Longest first, so no name is matched as the tail of a longer one.
        + "|".join(re.escape(b) for b in sorted(by_name, key=len, reverse=True))
        # Not followed by more name, nor by an extension (`notes` must not match `notes.md`).
        + r")(?![\w\-])(?!\.\w)"
    ) if by_name else None

    def lead_ok(lead):
        return (lead in ("", "./") or re.fullmatch(r"(?:\.\./)+", lead) is not None
                or lead == repo_name + "/" or lead.endswith("/" + repo_name + "/"))

    skipped, by_hand, counts = [], [], {"bare": 0, "path": 0}

    def fix_links(text, old_path, new_path):
        old_dir, new_dir = os.path.dirname(old_path), os.path.dirname(new_path)
        out, last, n = [], 0, 0
        for m in LINK_RE.finditer(text):
            target = m.group(1)
            if "://" in target or target.startswith(("/", "mailto:")):
                continue
            resolved = os.path.normpath(os.path.join(old_dir, target))
            if moved(resolved) == resolved and old_dir == new_dir:
                continue
            slash = "/" if target.endswith("/") else ""
            new_target = os.path.relpath(moved(resolved), new_dir or ".") + slash
            if new_target == os.path.normpath(target) + slash:
                continue
            out.append(text[last:m.start(1)])
            out.append(new_target)
            last = m.end(1)
            n += 1
        out.append(text[last:])
        return "".join(out), n

    def fix_text(text, path, mask_links):
        def repl(m):
            prefix, name = m.group("prefix"), m.group("name")
            entries = by_name[name]
            touches_slash = prefix.endswith("/") or text[m.end():m.end() + 1] == "/"
            if prefix == "":
                new_names = {os.path.basename(new) for _, new, _ in entries}
                if new_names == {name}:
                    return m.group(0)
                if len(new_names) > 1:
                    by_hand.append(f"{path}: bare `{name}` could mean {sorted(n for _, n, _ in entries)}")
                    return m.group(0)
                # A directory's bare name counts only as a path segment.
                if all(is_dir for _, _, is_dir in entries) and not touches_slash:
                    return m.group(0)
                counts["bare"] += 1
                return new_names.pop()
            # Longest folder first, so `verbdata/style/` is tried before `verbdata/`.
            for old, new, _ in sorted(entries, key=lambda e: len(e[0]), reverse=True):
                parent = os.path.dirname(old)
                parent = parent + "/" if parent else ""
                if prefix.endswith(parent) and lead_ok(prefix[:len(prefix) - len(parent)]):
                    counts["path"] += 1
                    return prefix[:len(prefix) - len(parent)] + new
            for old, new, _ in entries:
                parent = os.path.dirname(old) + "/"
                if parent.endswith("/" + prefix):
                    if os.path.dirname(old) == os.path.dirname(new):
                        counts["path"] += 1
                        return prefix + os.path.basename(new)
                    by_hand.append(f"{path}: `{m.group(0)}` is relative, and {old} changes folder")
                    return m.group(0)
            skipped.append(f"{path}: {m.group(0)}")
            return m.group(0)

        if name_re is None:
            return text
        if not mask_links:
            return name_re.sub(repl, text)
        # Link targets were settled by rule 1; rewriting them again would corrupt them.
        out, last = [], 0
        for m in LINK_RE.finditer(text):
            out.append(name_re.sub(repl, text[last:m.start(1)]))
            out.append(m.group(1))
            last = m.end(1)
        out.append(name_re.sub(repl, text[last:]))
        return "".join(out)

    # ---- compute every edit against the pre-move tree ----
    results, lines = {}, []
    for old_path in tracked:
        if old_path in excluded or not os.path.isfile(old_path):
            continue
        try:
            with open(old_path, encoding="utf-8") as f:
                text = f.read()
        except UnicodeDecodeError:
            continue
        new_path = moved(old_path)
        is_md = old_path.endswith(".md")
        new_text, links = text, 0
        if is_md:
            new_text, links = fix_links(new_text, old_path, new_path)
        before = counts["bare"] + counts["path"]
        if old_path not in links_only:
            new_text = fix_text(new_text, old_path, mask_links=is_md)
        if new_text != text:
            results[new_path] = new_text
            lines.append(f"{links:4d} links {counts['bare'] + counts['path'] - before:4d} mentions  {old_path}")

    if args["verbose"]:
        print("\n".join(lines))
    print(f"{len(file_moves)} files and {len(dir_moves)} directories to rename; "
          f"{len(results)} files to edit ({counts['path']} written-out paths, {counts['bare']} bare names, "
          f"plus link targets)")
    if links_only:
        print("link targets only in: " + ", ".join(sorted(links_only)))
    if skipped:
        print("\nSkipped, because the prefix names a different file. Check each one:")
        print("\n".join("  " + s for s in sorted(set(skipped))))
    if by_hand:
        print("\nNeeds a human:")
        print("\n".join("  " + s for s in sorted(set(by_hand))))
    if not args["apply"]:
        print("\ndry run; nothing changed. Re-run with --apply.")
        return

    # ---- move, then write ----
    for old, new in sorted(moves.items()):
        if os.path.dirname(new):
            os.makedirs(os.path.dirname(new), exist_ok=True)
        has_tracked = old in tracked_set or any(t.startswith(old + "/") for t in tracked)
        steps = [(old, new)]
        if old.lower() == new.lower():
            # A case-only rename needs a stop on the way on a case-insensitive filesystem.
            steps = [(old, new + ".renaming"), (new + ".renaming", new)]
        for a, b in steps:
            if has_tracked:
                subprocess.run(["git", "mv", a, b], check=True)
            else:
                os.rename(a, b)
    for path, text in results.items():
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
    print("\napplied")


main()
