#!/usr/bin/env python3
"""
Bloxstrap Gold — Desktop App Developer Watcher Daemon

Monitors bridge/COMMUNICATION.md for incoming replies and specifications
from the Website & Architecture Agent. When a new message is detected,
it immediately prints the event to stdout, triggering automatic reactive wakeup.
"""

import time
import os
import sys
import re

BRIDGE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "COMMUNICATION.md")
POLL_INTERVAL = 2.0

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

def main():
    print("🛰️ [APP_DEVELOPER_WATCHER] Started monitoring bridge/COMMUNICATION.md for incoming website agent messages...")
    sys.stdout.flush()

    last_seen_mtime = 0
    seen_msg_ids = set()

    # Initial scan of already existing messages (Message #001, #002)
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
                    
                    # Detect new messages from Website & Architecture Agent / Agent 1
                    if msg_id not in seen_msg_ids:
                        seen_msg_ids.add(msg_id)
                        if "website" in sender_lower or "architect" in sender_lower or "web" in sender_lower:
                            print("\n" + "="*80)
                            print(f"🔔 [NEW_WEBSITE_AGENT_MESSAGE_DETECTED]: Message #{msg['number']} received!")
                            print(f"From: {msg['from']}")
                            print(f"Timestamp: {msg['timestamp']}")
                            print(f"Status: {msg['status']}")
                            print("-" * 40)
                            print("Content:")
                            print(msg['body'])
                            print("="*80 + "\n")
                            sys.stdout.flush()

        except KeyboardInterrupt:
            print("\n[APP_DEVELOPER_WATCHER] Stopped.")
            break
        except Exception as e:
            print(f"[APP_DEVELOPER_WATCHER_ERROR] {e}")
            sys.stdout.flush()
            time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    main()
