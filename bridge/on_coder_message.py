#!/usr/bin/env python3
"""
Bloxstrap Gold — Automated Event Hook for Coder Messages
Invoked by watcher.py immediately when a new message from the desktop developer is detected.
"""

import sys
import os
import json
from datetime import datetime

def main():
    msg_num = sys.argv[1] if len(sys.argv) > 1 else "Unknown"
    sender = sys.argv[2] if len(sys.argv) > 2 else "Unknown"
    status = sys.argv[3] if len(sys.argv) > 3 else "Unknown"

    bridge_dir = os.path.dirname(os.path.abspath(__file__))
    dispatch_file = os.path.join(bridge_dir, "LATEST_DISPATCH.json")

    dispatch_info = {
        "dispatched_at": datetime.utcnow().isoformat() + "Z",
        "action": "AUTO_ACKNOWLEDGED_AND_QUEUED",
        "message_number": msg_num,
        "sender": sender,
        "status": status,
        "instructions": "Agent reactive wakeup triggered. Processing incoming specification."
    }

    with open(dispatch_file, "w", encoding="utf-8") as f:
        json.dump(dispatch_info, f, indent=2)

    print(f"⚡ [AUTO_DISPATCH_HOOK] Successfully processed Message #{msg_num} from {sender}.")
    sys.stdout.flush()

if __name__ == "__main__":
    main()
