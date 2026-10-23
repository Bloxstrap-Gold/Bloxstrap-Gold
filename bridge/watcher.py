#!/usr/bin/env python3
"""
Bloxstrap Gold — Cross-Agent Live Communication Watcher Daemon

Monitors bridge/COMMUNICATION.md for incoming messages from the Desktop App Developer.
When a new message is detected, it outputs an unmissable event to stdout (triggering an
automatic agent reactive wakeup), logs the payload to bridge/LATEST_EVENT.json and
bridge/events.log, and dispatches the on_coder_message hook.
"""

import time
import os
import sys
import re
import json
import subprocess
from datetime import datetime

BRIDGE_DIR = os.path.dirname(os.path.abspath(__file__))
BRIDGE_FILE = os.path.join(BRIDGE_DIR, "COMMUNICATION.md")
EVENT_FILE = os.path.join(BRIDGE_DIR, "LATEST_EVENT.json")
LOG_FILE = os.path.join(BRIDGE_DIR, "events.log")
HOOK_SCRIPT = os.path.join(BRIDGE_DIR, "on_coder_message.py")
POLL_INTERVAL = 1.5

def get_messages(content):
    """Parses message blocks from COMMUNICATION.md."""
    pattern = r"###\s+Message\s+#(\d+)\s*\n\*\*From:\*\*\s*([^\n]+)\s*\n\*\*To:\*\*\s*([^\n]+)\s*\n\*\*Timestamp:\*\*\s*`?([^`\n]+)`?\s*\n\*\*Status:\*\*\s*([^\n]+)\s*\n(.*?)(?=(?:###\s+Message\s+#|\Z))"
    matches = re.findall(pattern, content, re.DOTALL)
    messages = []
    for m in matches:
        messages.append({
            "number": m[0].strip(),
            "from": m[1].strip(),
            "to": m[2].strip(),
            "timestamp": m[3].strip(),
            "status": m[4].strip(),
            "body": m[5].strip()
        })
    return messages

def record_event(msg):
    """Logs the received message to LATEST_EVENT.json and events.log."""
    event_data = {
        "event": "NEW_CODER_MESSAGE",
        "detected_at": datetime.utcnow().isoformat() + "Z",
        "message_number": msg["number"],
        "from": msg["from"],
        "to": msg["to"],
        "timestamp": msg["timestamp"],
        "status": msg["status"],
        "body": msg["body"]
    }
    try:
        with open(EVENT_FILE, "w", encoding="utf-8") as f:
            json.dump(event_data, f, indent=2)
    except Exception as e:
        print(f"[BRIDGE_WATCHER_WARN] Could not write {EVENT_FILE}: {e}")

    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(f"[{datetime.utcnow().isoformat()}Z] Message #{msg['number']} from '{msg['from']}': {msg['status']}\n")
    except Exception as e:
        print(f"[BRIDGE_WATCHER_WARN] Could not append to {LOG_FILE}: {e}")

    # Dispatch hook script if available
    if os.path.exists(HOOK_SCRIPT):
        try:
            subprocess.run([sys.executable, HOOK_SCRIPT, msg["number"], msg["from"], msg["status"]], check=False)
        except Exception as e:
            print(f"[BRIDGE_WATCHER_WARN] Hook execution failed: {e}")

def main():
    print("🛰️ [BRIDGE_WATCHER] Started active monitoring on bridge/COMMUNICATION.md (poll: 1.5s)...")
    sys.stdout.flush()

    last_seen_mtime = 0
    seen_msg_ids = set()

    # Initial scan of already existing messages
    if os.path.exists(BRIDGE_FILE):
        try:
            last_seen_mtime = os.path.getmtime(BRIDGE_FILE)
            with open(BRIDGE_FILE, "r", encoding="utf-8") as f:
                content = f.read()
            for msg in get_messages(content):
                seen_msg_ids.add((msg["number"], msg["from"]))
        except Exception as e:
            print(f"Warning during initial scan: {e}")
            sys.stdout.flush()

    while True:
        try:
            time.sleep(POLL_INTERVAL)
            if not os.path.exists(BRIDGE_FILE):
                continue

            current_mtime = os.path.getmtime(BRIDGE_FILE)
            if current_mtime != last_seen_mtime:
                last_seen_mtime = current_mtime
                with open(BRIDGE_FILE, "r", encoding="utf-8") as f:
                    content = f.read()

                messages = get_messages(content)
                for msg in messages:
                    msg_id = (msg["number"], msg["from"])
                    sender_lower = msg["from"].lower()

                    # Detect new incoming messages from Desktop App Developer / Coder
                    if msg_id not in seen_msg_ids:
                        seen_msg_ids.add(msg_id)
                        if "desktop" in sender_lower or "coder" in sender_lower or "app" in sender_lower:
                            record_event(msg)
                            print("\n" + "="*80)
                            print(f"🔔 [NEW_CODER_MESSAGE_DETECTED]: Message #{msg['number']} received!")
                            print(f"From: {msg['from']}")
                            print(f"Timestamp: {msg['timestamp']}")
                            print(f"Status: {msg['status']}")
                            print("-" * 40)
                            print("Content:")
                            print(msg['body'][:800] + ("..." if len(msg['body']) > 800 else ""))
                            print("="*80 + "\n")
                            sys.stdout.flush()

        except KeyboardInterrupt:
            print("\n[BRIDGE_WATCHER] Stopped.")
            break
        except Exception as e:
            print(f"[BRIDGE_WATCHER_ERROR] {e}")
            sys.stdout.flush()
            time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    main()
