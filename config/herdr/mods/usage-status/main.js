import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { theme, exec, home, checking } from "herdr";

function resetLabel(timestamp) {
  if (!timestamp) return "";
  const date = new Date(timestamp * 1000);
  return ` · resets ${date.toLocaleString(undefined, { month: "short", day: "numeric", hour: "numeric", minute: "2-digit" })}`;
}

function codexLabel(data) {
  const limits = data?.rateLimitsByLimitId?.codex ?? data?.rateLimits;
  if (!limits) return data?.error ? "Codex unavailable" : "Codex usage unavailable";
  const windows = [
    ["5h", limits.primary],
    ["week", limits.secondary],
  ].filter(([, window]) => Boolean(window));
  if (!windows.length) return "Codex usage unavailable";
  return `Codex ${windows.map(([name, window]) => `${name} ${window.usedPercent}% used${resetLabel(window.resetsAt)}`).join(" / ")}`;
}

export default class UsageStatus extends View {
  init(_props, cx) {
    this.codex = null;
    this.copilot = null;
    if (checking()) return;
    cx.spawn(async cx => {
      for (;;) {
        const result = await exec("python3", [`${home()}/.config/herdr-app/mods/usage-status/usage.py`], { timeout: 60000 }).catch(() => null);
        try {
          const usage = JSON.parse(result?.stdout ?? "{}");
          this.codex = usage.codex;
          this.copilot = usage.copilot;
        } catch {
          this.codex = { error: true };
          this.copilot = { error: true };
        }
        cx.notify();
        await exec("sleep", ["300"]).catch(() => null);
      }
    });
  }

  render() {
    const t = theme();
    const copilot = this.copilot?.tokens == null
      ? `Copilot · ${this.copilot?.error ?? "checking usage"}`
      : `Copilot ${this.copilot.tokens.toLocaleString()} tokens this month`;
    return h_flex().size_full().px(14).gap(18).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .child(div().child(codexLabel(this.codex)))
      .child(div().child(copilot))
      .child(div().flex_1())
      .child(div().text_color(t.dim).child("Usage refreshes every 5 min"));
  }
}
