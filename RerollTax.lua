--- RerollTax
--- The shop reroll cost never resets. It starts at $1, climbs $1 per reroll,
--- and that climb carries across every round for the rest of the run.
---
--- Architecture (verified against the project's vanilla source):
---
---   common_events.lua : calculate_reroll_cost(skip_increment)
---       reroll_cost = (round_resets.temp_reroll_cost or round_resets.reroll_cost)
---                     + current_round.reroll_cost_increase
---     The +$1 step is ALREADY vanilla -- reroll_cost_increase increments by 1
---     per paid reroll. We do not touch the increment.
---
---   state_events.lua : new_round()
---       G.GAME.current_round.reroll_cost_increase = 0
---     THIS is the only thing that makes rerolls cheap again. It is the single
---     line this mod neutralises. Note it runs inside a queued E_MANAGER event,
---     not synchronously, so a plain wrapper around new_round() that restores
---     the value immediately would be overwritten when the event fires. We keep
---     our own counter on G.GAME instead (persists in the save) and re-derive
---     current_round.reroll_cost_increase from it.
---
---   game.lua : G.GAME.base_reroll_cost = 5
---     Reroll Surplus and Reroll Glut each take $2 off, which is exactly why
---     "start at $1 with both vouchers" is the correct number. We set the base
---     to 1 directly at run start rather than granting the vouchers, and remove
---     both from the pool so they cannot stack it below 1.
---
---   FREE REROLLS ARE A CHEESE VECTOR -- confirmed at source. In
---   calculate_reroll_cost the free_rerolls branch sets cost 0 and RETURNS
---   before the increment, so a free reroll does not count toward the tax at
---   all. Chaos the Clown (1 free reroll per shop) and the D6 tag (rerolls
---   free this shop) are therefore banned by default.

--- Stable mod reference captured at load time (SMODS.current_mod is nil later).
local THIS_MOD = SMODS.current_mod

THIS_MOD.config = THIS_MOD.config or {}
local cfg = THIS_MOD.config
if cfg.enabled      == nil then cfg.enabled      = true end
if cfg.start_cost   == nil then cfg.start_cost   = 1    end
if cfg.ban_cheese   == nil then cfg.ban_cheese   = true end
if cfg.ban_vouchers == nil then cfg.ban_vouchers = true end

--- Keys to suppress when ban_cheese / ban_vouchers are on.
--- NOTE: the project's globals.lua is a trimmed copy without the full
--- G.P_CENTERS table, so these keys are from convention, not read from source.
--- If a ban silently does nothing, print the key in-game and correct it here.
local CHEESE_JOKERS  = { j_chaos = true }             -- Chaos the Clown
local CHEESE_TAGS    = { tag_d_six = true }           -- D6 Tag
local REROLL_VOUCHERS = { v_reroll_surplus = true, v_reroll_glut = true }

local function on() return cfg.enabled end

----------------------------------------------------------------------
-- Core: keep our own run-long reroll counter.
----------------------------------------------------------------------
local ref_calculate_reroll_cost = calculate_reroll_cost

function calculate_reroll_cost(skip_increment)
    if not on() then return ref_calculate_reroll_cost(skip_increment) end

    local cr = G.GAME.current_round
    if cr.free_rerolls < 0 then cr.free_rerolls = 0 end
    if cr.free_rerolls > 0 then cr.reroll_cost = 0; return end

    G.GAME.ntg_reroll_tax = G.GAME.ntg_reroll_tax or 0
    if not skip_increment then
        G.GAME.ntg_reroll_tax = G.GAME.ntg_reroll_tax + 1
    end

    -- Mirror into the vanilla field so anything else reading it stays correct.
    cr.reroll_cost_increase = G.GAME.ntg_reroll_tax
    cr.reroll_cost = (G.GAME.round_resets.temp_reroll_cost
                      or G.GAME.round_resets.reroll_cost)
                     + G.GAME.ntg_reroll_tax
end

----------------------------------------------------------------------
-- new_round() zeroes reroll_cost_increase inside a queued event.
-- Queue our own event behind it to re-derive the cost from our counter.
----------------------------------------------------------------------
local ref_new_round = new_round

function new_round()
    ref_new_round()
    if not on() then return end
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            calculate_reroll_cost(true)   -- true = recalc without incrementing
            return true
        end
    }))
end

----------------------------------------------------------------------
-- Run start: set the base cost and clear the counter.
----------------------------------------------------------------------
local ref_start_run = Game.start_run

function Game:start_run(args)
    ref_start_run(self, args)
    if not on() then return end

    -- Fresh runs start clean; a loaded save keeps whatever it had.
    G.GAME.ntg_reroll_tax = G.GAME.ntg_reroll_tax or 0

    G.GAME.round_resets.reroll_cost = cfg.start_cost
    calculate_reroll_cost(true)
end

----------------------------------------------------------------------
-- Pool suppression for the cheese vectors and the now-redundant vouchers.
----------------------------------------------------------------------
local ref_get_current_pool = get_current_pool

function get_current_pool(_type, _rarity, _legendary, _append)
    local pool, key = ref_get_current_pool(_type, _rarity, _legendary, _append)
    if not on() then return pool, key end

    for i = 1, #pool do
        local k = pool[i]
        if (cfg.ban_cheese   and (CHEESE_JOKERS[k] or CHEESE_TAGS[k]))
        or (cfg.ban_vouchers and REROLL_VOUCHERS[k]) then
            pool[i] = 'UNAVAILABLE'
        end
    end
    return pool, key
end

----------------------------------------------------------------------
-- Config tab.
----------------------------------------------------------------------
THIS_MOD.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = 'cm', padding = 0.05, colour = G.C.CLEAR },
        nodes = {
            create_toggle({
                label = 'Enable RerollTax',
                ref_table = cfg, ref_value = 'enabled',
            }),
            create_toggle({
                label = 'Ban Chaos the Clown + D6 Tag',
                ref_table = cfg, ref_value = 'ban_cheese',
            }),
            create_toggle({
                label = 'Remove reroll vouchers from pool',
                ref_table = cfg, ref_value = 'ban_vouchers',
            }),
        }
    }
end
