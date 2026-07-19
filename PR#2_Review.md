| Area | Result |
| --- | --- |
| Swift models vs backend JSON | Field names and types match. New size/idempotency constraints need frontend alignment. |
| Paths, statuses, error codes | Match: health `200`, create/enrich `202`, list/detail/search `200`, retry `404/409/503`, and documented error codes. |
| Search return structure | Matches exactly: `query`, then `results[].capture/score/keyword_score/semantic_score`. |
| Polling behavior | Implementation matches the 2-second/60-second terminal-state contract; tests are missing. |
| Shared-doc accuracy | Fails current-state review; Layer 6/7 and stress-hardening status is stale, and decision IDs conflict. |
| Layer 7 consistency | Wire format remains fully compatible. Generic local fallback and missing 512-character guard break behavioral consistency. |
