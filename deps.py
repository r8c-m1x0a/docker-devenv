import os
import subprocess

def install(deps):
    for dep in deps:
        if not os.path.isdir(f"deps/{dep['name']}"):
            branch_or_tag = dep.get('tag', dep.get('branch'))
            branch_or_tag = ["-b", branch_or_tag] if branch_or_tag is not None else []
            cmd = ["git", "clone", dep['url']] + branch_or_tag + [f"deps/{dep['name']}", "--depth", "1"]
            print(f"Running {' '.join(cmd)}")
            subprocess.run(cmd, check=True)

    return 0

