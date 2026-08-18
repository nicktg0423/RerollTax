# RerollTax

A Balatro mod that makes the shop reroll cost permanent. It starts at $1, climbs $1 with every reroll, and **never resets between rounds**, so every cheap reroll early is a bill you pay for the rest of the run.

---

## What it does

| Behaviour | Detail |
|---|---|
| Starting cost | $1 |
| Per reroll | +$1, permanently |
| Between rounds | No reset. The climb carries for the whole run. |
| Chaos the Clown | Removed |
| Skip tag that starts rerolls at $0 | Removed |
| Reroll Surplus / Reroll Glut | Removed |

In the base game the reroll price climbs while you are in a shop and then goes back to its starting price on the next round. This mod removes the reset. Reroll ten times in Ante 1 and every shop for the rest of the run opens at $11 and keeps going up from there.

---

## Why three things are removed

**Chaos the Clown** gives one free reroll per shop. Free rerolls do not count toward the climbing price, so over a full run it would quietly erase a large part of the cost.

**The skip tag that starts rerolls at $0** cannot keep that promise here, because your accumulated cost still applies on top of the $0. It is removed so nothing in the game offers you something the mod will not honour.

**Reroll Surplus and Reroll Glut** each make rerolls cost $2 less. The $1 starting price already assumes both of them, so buying either would push the price below where the challenge begins.

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

No `lovely.toml` is required. This mod patches no vanilla files.

Three toggles live on the mod's config tab:

- **Enable RerollTax**
- **Ban Chaos the Clown + D6 Tag** (the Joker and the skip tag above)
- **Remove reroll vouchers from pool**

Turning the last two off will let the reroll price be reduced or bypassed, which defeats the point of the mod.

---

## Compatibility

Single-player Balatro with Steamodded. The reroll price carries through saving and loading. Nothing outside the shop reroll price and the three removed items is changed.

---

## Credits

Built by NickTG for a Balatro challenge run series.

Concept suggested by a viewer on the [NickTG](http://www.youtube.com/@NickTGaming) channel.

## License

MIT. See LICENSE.
