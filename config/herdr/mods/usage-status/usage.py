#!/usr/bin/env python3
"""Read the signed-in Codex account's rate limits and GitHub Copilot metrics."""

import json
import subprocess
from datetime import datetime, timezone


def codex_usage():
    process = subprocess.Popen(
        ["codex", "app-server"], stdin=subprocess.PIPE,
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
    )
    try:
        messages = [
            {"id": 1, "method": "initialize", "params": {
                "clientInfo": {"name": "herdr-usage-status", "title": "Herdr usage status", "version": "1"},
                "capabilities": {},
            }},
            {"method": "initialized", "params": {}},
            {"id": 2, "method": "account/rateLimits/read", "params": {}},
        ]
        for message in messages:
            process.stdin.write(json.dumps(message) + "\n")
        process.stdin.flush()
        for line in process.stdout:
            message = json.loads(line)
            if message.get("id") == 2:
                if "error" in message:
                    return {"error": message["error"].get("message", "Codex usage unavailable")}
                return message.get("result", {})
        return {"error": "Codex did not return a usage snapshot"}
    finally:
        process.kill()
        process.wait()


def copilot_usage():
    today = datetime.now(timezone.utc).date()
    result = subprocess.run(
        ["gh", "api", "/orgs/atgse/copilot/metrics/reports/users-28-day/latest"],
        capture_output=True, text=True, timeout=15,
    )
    if result.returncode:
        error = result.stderr.strip()
        if "Insufficient permissions" in error or "403" in error:
            return {"error": "Needs atgse Copilot metrics access"}
        if "Not Found" in error or "404" in error:
            return {"error": "Copilot metrics are not enabled for atgse"}
        return {"error": "GitHub CLI unavailable or not authenticated"}
    links = json.loads(result.stdout).get("download_links", [])
    if not links:
        return {"error": "No Copilot metrics report available"}
    report = subprocess.run(["curl", "-fsSL", links[0]], capture_output=True, text=True, timeout=30)
    if report.returncode:
        return {"error": "Could not download Copilot metrics report"}

    login = subprocess.run(["gh", "api", "/user", "--jq", ".login"], capture_output=True, text=True, timeout=10)
    if login.returncode:
        return {"error": "GitHub CLI unavailable or not authenticated"}
    own = [json.loads(line) for line in report.stdout.splitlines() if line]
    own = [row for row in own if row.get("user_login", "").lower() == login.stdout.strip().lower()
           and row.get("day", "") >= today.replace(day=1).isoformat()]
    tokens = 0
    for row in own:
        for item in row.get("totals_by_client") or []:
            usage = item.get("token_usage") or {}
            tokens += usage.get("prompt_tokens_sum", 0) + usage.get("output_tokens_sum", 0)
    return {"tokens": tokens, "through": today.isoformat()}


try:
    output = {"codex": codex_usage(), "copilot": copilot_usage()}
except Exception as error:
    output = {"error": str(error)}
print(json.dumps(output))
