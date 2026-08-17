# RerollTax

A Balatro mod that makes the shop reroll cost permanent. It starts at $1, climbs $1 with every reroll, and **never resets between rounds** — so every cheap reroll early is a bill you pay for the rest of the run.

---

## What it does

| Behaviour | Detail |
|---|---|
| Starting cost | $1 — the same price you'd get owning both reroll vouchers |
| Per reroll | +$1, permanently |
| Between rounds | No reset. The climb carries for the whole run. |
| Chaos the Clown | Removed from the pool |
| D6 Tag | Removed from the pool |
| Reroll Surplus / Reroll Glut | Removed from the pool |

Vanilla Balatro already increments the reroll cost by $1 per reroll — that part is not this mod. What vanilla also does is wipe the counter at the start of every round, in a single line inside `new_round()`:

```lua
G.GAME.current_round.reroll_cost_increase = 0
```

Removing that line is the entire challenge. Rerolling ten times in Ante 1 is cheap and it feels free; it also means every shop for the rest of the run opens at $11 and goes up from there.

---

## Why those three things are banned

**Chaos the Clown is a genuine bypass.** In `calculate_reroll_cost`, the free-reroll branch sets the cost to zero and `return`s *before* the increment runs:

```lua
if G.GAME.current_round.free_rerolls > 0 then
    G.GAME.current_round.reroll_cost = 0
    return
end
```

A free reroll therefore doesn't just cost nothing, it doesn't count. Chaos gives one per shop, which would quietly erase a large share of the tax over a full run.

**The D6 Tag is not a bypass, and is banned for tidiness rather than necessity.** It sets `temp_reroll_cost`, which replaces the *base* in the final sum:

```lua
reroll_cost = (temp_reroll_cost or reroll_cost) + reroll_cost_increase
```

Your accumulated increase still gets added on top, so the tag is worth exactly $1 off, not free rerolls. Turn `ban_cheese` off if you'd rather leave it in.

**The reroll vouchers are redundant here.** Base reroll cost is $5 and each voucher takes $2 off, which is exactly why $1 is the right starting number. Owning them on top would push the base below $1 and into negatives. They only ever modify the base, never the counter, so buying one could never have reset the tax — they're removed to keep the arithmetic honest rather than to protect the mechanic.

---


## Installation

Requires [Steamodded](https://github.com/Steamodded/smods) `1.0.0~BETA-0400a` or newer.

Drop the `RerollTax` folder into your Balatro `Mods/` directory:

```
Mods/
  RerollTax/
    RerollTax.json
    RerollTax.lua
```

No `lovely.toml` is required — this mod patches no vanilla files.

Three toggles live on the mod's config tab:

- **Enable RerollTax** — master switch
- **Ban Chaos the Clown + D6 Tag** — leave on unless you want the tag back
- **Remove reroll vouchers from pool** — turn off only if you also raise the starting cost

---

## Notes on behaviour

**The reset happens inside a queued event, not a function body.** `new_round()` clears the counter from within an `E_MANAGER` event, so wrapping the function and restoring the value immediately doesn't work — the event fires afterwards and wipes it again. This mod keeps its own counter at `G.GAME.ntg_reroll_tax` instead and re-derives the cost from it on every call. Any vanilla code that zeroes `reroll_cost_increase` is simply overwritten on the next recalculation.

**The counter persists through save and load,** because it lives on `G.GAME`.

**Reroll Glut has an unlock condition** of 100 lifetime shop rerolls. On a profile where it isn't unlocked yet it would never have appeared regardless of the ban.

---

## Compatibility

- Single-player Balatro with Steamodded.
- Overrides `calculate_reroll_cost`, wraps `new_round`, `Game.start_run` and `get_current_pool`. Each wraps the original rather than replacing it, so other mods layering on the same functions should coexist — but a mod that replaces any of them wholesale could conflict.
- Changes nothing outside the shop reroll price and the three banned pool entries.

---

## Credits

Built by NickTG for a Balatro challenge run series.

Concept suggested by a viewer on the [NickTG](http://www.youtube.com/@NickTGaming) channel.

## License

MIT. See LICENSE.
