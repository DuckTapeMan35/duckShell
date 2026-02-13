#!/usr/bin/env python3
"""
Output wal colors only when they actually change.
Monitors ~/.cache/wal/colors for changes and prints contents when modified.
"""

import os
import sys
import hashlib
import time
import signal
import ctypes

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


CONFIG_FILE = os.path.expanduser("~/.config/quickshell/config.conf")
# Resolve the symlink to get the actual file
ACTUAL_FILE = os.path.realpath(CONFIG_FILE)
WATCH_DIR = os.path.dirname(ACTUAL_FILE)

libc = ctypes.CDLL("libc.so.6")
PR_SET_PDEATHSIG = 1
libc.prctl(PR_SET_PDEATHSIG, signal.SIGTERM)

def handle_term(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_term)
signal.signal(signal.SIGHUP, handle_term)

class WalColorHandler(FileSystemEventHandler):
    def __init__(self):
        self.prev_hash = ""
        self.process_event()

    def get_file_hash(self):
        """Calculate SHA256 hash of the colors file."""
        try:
            with open(ACTUAL_FILE, 'rb') as f:
                return hashlib.sha256(f.read()).hexdigest()
        except (IOError, OSError) as e:
            print(f"Error reading file: {e}", file=sys.stderr)
            return None

    def process_event(self):
        """Check if file changed and output if it did."""
        current_hash = self.get_file_hash()
        if current_hash is None:
            return

        if current_hash != self.prev_hash:
            try:
                with open(ACTUAL_FILE, 'r') as f:
                    print(f.read(), end='')
                    sys.stdout.flush()
                self.prev_hash = current_hash
            except (IOError, OSError) as e:
                print(f"Error reading file: {e}", file=sys.stderr)

    def on_closed(self, event):
        """Called when a file is closed after writing."""
        if not event.is_directory and os.path.abspath(event.src_path) == ACTUAL_FILE:
            self.process_event()


def main():
    # Ensure the file exists
    if not os.path.exists(ACTUAL_FILE):
        print(f"Error: {ACTUAL_FILE} does not exist", file=sys.stderr)
        sys.exit(1)

    # Set up watchdog observer
    event_handler = WalColorHandler()
    observer = Observer()
    observer.schedule(event_handler, path=WATCH_DIR, recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    
    observer.join()


if __name__ == "__main__":
    main()
