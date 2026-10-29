"""Fetch only the Windows release template from the official multi-platform ZIP.

Uses HTTPS byte ranges and zipfile's CRC validation; does not install globally.
"""
import io
import pathlib
import sys
import urllib.request
import zipfile

URL = "https://github.com/godotengine/godot-builds/releases/download/4.4.1-stable/Godot_v4.4.1-stable_export_templates.tpz"

class RemoteZip(io.RawIOBase):
    def __init__(self):
        request = urllib.request.Request(URL, headers={"Range": "bytes=0-0", "User-Agent": "LagosLife-build"})
        with urllib.request.urlopen(request, timeout=90) as response:
            if response.status != 206:
                raise RuntimeError("The server does not support partial downloads")
            self.url = response.url
            self.length = int(response.headers["Content-Range"].split("/")[-1])
        self.position = 0

    def seekable(self): return True
    def readable(self): return True
    def tell(self): return self.position
    def seek(self, offset, whence=0):
        self.position = offset if whence == 0 else self.position + offset if whence == 1 else self.length + offset
        return self.position
    def read(self, size=-1):
        if size < 0: size = self.length - self.position
        size = min(size, self.length - self.position)
        if size <= 0: return b""
        start = self.position
        request = urllib.request.Request(self.url, headers={"Range": f"bytes={start}-{start + size - 1}", "User-Agent": "LagosLife-build"})
        with urllib.request.urlopen(request, timeout=120) as response:
            if response.status != 206 or not response.headers.get("Content-Range", "").startswith(f"bytes {start}-"):
                raise RuntimeError("The server returned an unexpected byte range")
            result = response.read()
        if len(result) != size: raise RuntimeError("Incomplete template download")
        self.position += len(result)
        return result

output = pathlib.Path(sys.argv[1]).resolve()
with zipfile.ZipFile(RemoteZip()) as archive:
    member = next(name for name in archive.namelist() if name.endswith("/windows_release_x86_64.exe"))
    content = archive.read(member)  # ZIP member CRC is checked by zipfile.
    if content[:2] != b"MZ": raise RuntimeError("Template is not a Windows executable")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(content)
    print(f"Verified and saved {member}: {len(content):,} bytes", flush=True)
