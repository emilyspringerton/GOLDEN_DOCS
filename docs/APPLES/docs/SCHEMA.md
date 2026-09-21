# APPLES — Apple JSON Schema Reference

**Date**: 2026-06-09

---

## Full Schema

```json
{
  "id": "apple-001",
  "number": 1,

  "type": "completion",
  // Valid types:
  //   completion         — a backlog item was completed
  //   rsi_iteration      — RSI loop completed one tic-toc cycle
  //   signal_observation — FatBaby Emily published a system observation
  //   escalation         — something requires CEO attention
  //   status             — routine status/health check
  //   device_event       — MJOLNIR app event (token registered, notification delivered)

  "title": "BACKLOG: ✓ IDUNA embedded SQLite backend",
  // ≤ 140 chars. Human-readable. Past tense.

  "body": "Full markdown body with details.",
  // Unlimited. Markdown. May include code blocks, links, diffs.

  "source_repo": "IDUNA",
  // Valid: PRRJECT_FATBABY | EMILY | IDUNA | SHANKPIT | TYLER | MJOLNIR | APPLES
  //        emily.cli | GoblinFoxDragon

  "source_agent": "claude-code",
  // Valid: emily-prime | claude-code | fatbaby-emily | tyler | mjolnir-emily

  "severity": "normal",
  // Valid: critical | high | normal | low | info

  "requires_ceo_visibility": false,
  // true → MJOLNIR sends CRITICAL push notification + Gmail escalation

  "filed_at": "2026-06-07T09:14:21Z",
  // ISO 8601 UTC

  "metadata": {
    // Arbitrary key-value. Examples:
    "backlog_item": "IDUNA embedded SQLite backend",
    "commit_hash": "8490bb5",
    "tokens_used": 4200,
    "rsi_cycle": 3,
    "improvement_type": "token_efficiency"
  }
}
```

---

## Type Reference

### completion
Filed when a backlog item in `EMILY/BACKLOG.md` is checked `[x]`.  
`title` format: `"BACKLOG: ✓ <item name>"`

### rsi_iteration  
Filed at the end of each RSI tic-toc cycle by `rsi-loop.sh`.  
`metadata` includes: `cycle_number`, `preset_used`, `tokens_used`, `improvements_shipped`.

### signal_observation
Filed when FatBaby-Emily publishes an observation via `fatbaby_write_observation`.  
`metadata` includes: `affected_tickers`, `signal_ids`, `observation_type`.

### escalation
Filed when something requires Emily Springerton's attention.  
`requires_ceo_visibility` is always `true`.  
Triggers MJOLNIR CRITICAL push + Gmail.

### status
Filed by routine health checks. Low severity, never CEO visible.

### device_event
Filed by MJOLNIR when a device action occurs (FCM token registered, notification tapped).
`source_agent: "mjolnir-emily"`. Enables Emily Prime to audit mobile delivery.

---

*APPLES SCHEMA | 2026-06-09*
