#!/usr/bin/env python3

import os
from pathlib import Path
import shutil
import subprocess
import sys


SOURCE_DIR = Path("/usr/share/glib-2.0/schemas")
CACHE_HOME = Path(
    os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")
)
SCHEMA_DIR = CACHE_HOME / "kannada-plaza" / "chrome-gsettings"
XSETTINGS_FILE = "org.gnome.settings-daemon.plugins.xsettings.gschema.xml"
LEGACY_KEY = """    <key name="antialiasing" enum="org.gnome.settings-daemon.GsdFontAntialiasingMode">
      <default>'grayscale'</default>
      <summary>Font antialiasing compatibility setting</summary>
    </key>
"""


def main() -> None:
    if not SOURCE_DIR.is_dir():
        raise RuntimeError(f"GNOME schemas directory not found: {SOURCE_DIR}")

    SCHEMA_DIR.mkdir(parents=True, exist_ok=True)
    for source in SOURCE_DIR.iterdir():
        if source.suffix in {".xml", ".override"}:
            shutil.copy2(source, SCHEMA_DIR / source.name)

    xsettings_path = SCHEMA_DIR / XSETTINGS_FILE
    contents = xsettings_path.read_text(encoding="utf-8")
    schema_start = contents.find(
        'id="org.gnome.settings-daemon.plugins.xsettings" '
    )
    schema_end = contents.find("</schema>", schema_start)
    if schema_start < 0 or schema_end < 0:
        raise RuntimeError(f"Could not find the XSettings schema in {xsettings_path}")

    schema_contents = contents[schema_start:schema_end]
    if 'name="antialiasing"' not in schema_contents:
        contents = (
            contents[:schema_end] + LEGACY_KEY + contents[schema_end:]
        )
        xsettings_path.write_text(contents, encoding="utf-8")

    compiler = shutil.which("glib-compile-schemas")
    if compiler is None:
        raise RuntimeError("glib-compile-schemas is required to prepare Chrome")
    subprocess.run([compiler, str(SCHEMA_DIR)], check=True)
    print(SCHEMA_DIR)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Could not prepare Chrome settings schemas: {error}", file=sys.stderr)
        raise SystemExit(1) from error
