-- Extend Page

Partner_API = SMODS.current_mod

Partner_API.Partner = SMODS.Center:extend{
    unlocked = true,
    discovered = false,
    config = {},
    set = "Partner",
    class_prefix = "pnr",
    required_params = {"key", "atlas", "pos"},
    pre_inject_class = function(self)
        G.P_CENTER_POOLS[self.set] = {}
    end,
    set_card_type_badge = function(self, card, badges)
        badges[#badges+1] = create_badge(localize("k_partner"), G.C.DARK_EDITION, G.C.WHITE)
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        if self.config.extra.related_card then
            local link_key = self.config.extra.related_card
            if link_key and next(SMODS.find_card(link_key)) then
                info_queue[#info_queue+1] = {key = "partner_benefits", set = "Other"}
                --local main_end = {}
                --localize{type = "other", key = "partner_benefits", nodes = main_end}
                --main_end = main_end[1]
                --desc_nodes[#desc_nodes+1] = main_end
            end
        end
    end
}

-- Collection Page

Partner_API.custom_collection_tabs = function()
    local tally = 0
    for _, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v.unlocked then
            tally = tally + 1
        end
    end
    return {UIBox_button({button = "your_collection_partners", label = {localize("b_partners")}, count = {tally = tally, of = #G.P_CENTER_POOLS["Partner"]}, minw = 5, id = "your_collection_partners"})}
end

G.FUNCS.your_collection_partners = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = create_UIBox_your_collection_partners(),
    }
end

function create_UIBox_your_collection_partners()
    local deck_tables = {}
    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(G.ROOM.T.x, G.ROOM.T.h, 3.6*G.CARD_W, 0.7*G.CARD_H, {card_limit = 4, type = "title", highlight_limit = 0, collection = true})
        table.insert(deck_tables, {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
            {n=G.UIT.O, config={object = G.your_collection[j]}}
        }})
    end
    local partner_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS["Partner"]/(4*#G.your_collection)) do
        table.insert(partner_options, localize("k_page").." "..tostring(i).."/"..tostring(math.ceil(#G.P_CENTER_POOLS["Partner"]/(4*#G.your_collection))))
    end
    for i = 1, 4 do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Partner"][i+(j-1)*4]
            local card = Card(G.your_collection[j].T.x+G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*46/71, G.CARD_H*58/95, nil, center)
            --card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
    local t =  create_UIBox_generic_options({back_func = "your_collection_other_gameobjects", infotip = localize("ml_partner_unique_ability"), contents = {
        {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}, 
        {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = partner_options, w = 4.5, cycle_shoulders = true, opt_callback = "your_collection_partner_page", current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = "wide"}})
        }}
    }})
    return t
end

G.FUNCS.your_collection_partner_page = function(args)
    if not args or not args.cycle_config then return end
    for j = 1, #G.your_collection do
        for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
        end
    end
    for i = 1, 4 do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Partner"][i+(j-1)*4+(4*#G.your_collection*(args.cycle_config.current_option-1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x+G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
            --card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
end

-- UI Page

Partner_API.config_tab = function()
    return {n=G.UIT.ROOT, config = {align = "cm", padding = 0.05, colour = G.C.CLEAR}, nodes={
        create_toggle({label = localize("k_enable_partner"), ref_table = Partner_API.config, ref_value = "enable_partner"}),
    }}
end

local Card_set_sprites_ref = Card.set_sprites
function Card:set_sprites(_center, _front)
    Card_set_sprites_ref(self, _center, _front)
    if _center and _center.set == "Partner" and not _center.unlocked then
        self.children.center.atlas = G.ASSET_ATLAS["partner_Partner"]
        self.children.center:set_sprite_pos({x = 0, y = 4})
    end
end

local Card_update_ref = Card.update
function Card:update(dt)
    Card_update_ref(self, dt)
    if self.ability.set == "Partner" and not self.states.drag.is then
        if self.T.x+self.T.w > G.ROOM.T.w then
            self.T.x = G.ROOM.T.w-self.T.w
        elseif self.T.x < 0 then
            self.T.x = 0
        end
        if self.T.y+self.T.h > G.ROOM.T.h then
            self.T.y = G.ROOM.T.h-self.T.h
        elseif self.T.y < 0 then
            self.T.y = 0
        end
    end
end

local create_UIBox_card_unlock_ref = create_UIBox_card_unlock
function create_UIBox_card_unlock(card_center)
    local ret = create_UIBox_card_unlock_ref(card_center)
    local title = ret.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].config
    if card_center.set == "Partner" then
        title.object:remove()
        title.object = DynaText({string = {localize("k_partner")}, colours = {G.C.BLUE}, shadow = true, rotate = true, bump = true, pop_in = 0.3, pop_in_rate = 2, scale = 1.2})
    end
    return ret
end

local create_UIBox_notify_alert_ref = create_UIBox_notify_alert
function create_UIBox_notify_alert(_achievement, _type)
    local ret = create_UIBox_notify_alert_ref(_achievement, _type)
    local title = ret.nodes[1].nodes[1].nodes[2].nodes[1].nodes[1].config
    if _type == "Partner" then
        title.text = localize("k_partner")
    end
    return ret
end

function Card:add_partner_speech_bubble(forced_key)
    if self.children.speech_bubble then self.children.speech_bubble:remove() end
    local align = nil
    if self.T.x+self.T.w/2 > G.ROOM.T.w/2 then align = "cl" end
    self.config.speech_bubble_align = {align = align or "cr", offset = {x=align and -0.1 or 0.1,y=0}, parent = self}
    self.children.speech_bubble = UIBox{
        definition = G.UIDEF.partner_speech_bubble(forced_key),
        config = self.config.speech_bubble_align
    }
    self.children.speech_bubble:set_role{role_type = "Minor", xy_bond = "Strong", r_bond = "Weak", major = self}
    self.children.speech_bubble.states.visible = false
end

function G.UIDEF.partner_speech_bubble(forced_key)
    local text = {}
    localize{type = "quips", key = forced_key or "pq_1", nodes=text}
    local row = {}
    for k, v in ipairs(text) do
        row[#row+1] = {n=G.UIT.R, config={align = "cl"}, nodes=v}
    end
    local t = {n=G.UIT.ROOT, config = {align = "cm", minh = 1, r = 0.3, padding = 0.07, minw = 1, colour = G.C.JOKER_GREY, shadow = true}, nodes={
        {n=G.UIT.C, config={align = "cm", minh = 1, r = 0.2, padding = 0.1, minw = 1, colour = G.C.WHITE}, nodes={
            {n=G.UIT.C, config={align = "cm", minh = 1, r = 0.2, padding = 0.03, minw = 1, colour = G.C.WHITE}, nodes=row}
        }}
    }}
    return t
end

function Card:partner_say_stuff(n, not_first)
    self.talking = true
    if not not_first then 
        G.E_MANAGER:add_event(Event({trigger = "after", delay = 0.1, func = function()
            if self.children.speech_bubble then self.children.speech_bubble.states.visible = true end
            self:partner_say_stuff(n, true)
        return true end}))
    else
        if n <= 0 then self.talking = false; return end
        play_sound("voice"..math.random(1, 11), G.SPEEDFACTOR*(math.random()*0.2+1), 0.5)
        self:juice_up()
        G.E_MANAGER:add_event(Event({trigger = "after", blockable = false, blocking = false, delay = 0.13, func = function()
            self:partner_say_stuff(n-1, true)
        return true end}))
    end
end

function Card:remove_partner_speech_bubble()
    if self.children.speech_bubble then self.children.speech_bubble:remove(); self.children.speech_bubble = nil end
end

local Card_draw_ref = Card.draw
function Card:draw(layer)
    Card_draw_ref(self, layer)
    if self.children.speech_bubble then
        self.children.speech_bubble:draw()
    end
end

local Card_move_ref = Card.move
function Card:move(dt)
    Card_move_ref(self, dt)
    if self.children.speech_bubble then
        local align = nil
        if self.T.x+self.T.w/2 > G.ROOM.T.w/2 then align = "cl" end
        self.children.speech_bubble:set_alignment({type = align or "cr", offset = {x=align and -0.1 or 0.1,y=0}, parent = self})
    end
end

-- New Run Page

G.FUNCS.run_setup_partners_option = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = create_UIBox_partners_option(),
        config = {no_esc = true}
    }
end

function create_UIBox_partners_option()
    local partner_pool = G.P_CENTER_POOLS["Partner"]
    G.GAME.viewed_partner = G.P_CENTER_POOLS["Partner"][G.PROFILES[G.SETTINGS.profile].MEMORY.partner] or G.P_CENTER_POOLS["Partner"][1]
    G.partner_area = CardArea(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W, G.CARD_H, {card_limit = 1, type = "title", highlight_limit = 0})
    local center = G.GAME.viewed_partner
    local card = Card(G.partner_area.T.x+G.partner_area.T.w/2-G.CARD_W*23/71, G.partner_area.T.y+G.partner_area.T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
    local UI_table = G.GAME.viewed_partner.unlocked and generate_card_ui(G.GAME.viewed_partner, nil, nil, "Partner") or generate_card_ui(G.GAME.viewed_partner, nil, nil, "Locked")
    local partner_main = {n=G.UIT.ROOT, config={align = "cm", minw = 3.5, minh = 1.75, id = G.GAME.viewed_partner.name, colour = G.C.CLEAR}, nodes={desc_from_rows(UI_table.main, true, 3.5)}}
    --card.sticker = get_joker_win_sticker(center)
    card.states.hover.can = false
    G.partner_area:emplace(card)
    local ordered_names, viewed_partner = {}, 1
    for k, v in ipairs(partner_pool) do
        ordered_names[#ordered_names+1] = v.name
        if v.name == G.GAME.viewed_partner.name then
            viewed_partner = k
        end
    end
    local t = create_UIBox_generic_options({no_back = true, contents = {
        create_option_cycle({options = ordered_names, opt_callback = "change_viewed_partner", current_option = viewed_partner, colour = G.C.RED, w = 4.5, focus_args = {snap_to = true}, mid = 
            {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes={
                {n=G.UIT.R, config={align = "cm", padding = 0.2, colour = G.C.BLACK, r = 0.2}, nodes={
                    {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                        {n=G.UIT.O, config={object = G.partner_area}}
                    }},
                    {n=G.UIT.C, config={align = "tm", minw = 3.7, minh = 2.1, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                        {n=G.UIT.R, config={align = "cm", emboss = 0.1, r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                            {n=G.UIT.O, config={id = nil, func = "RUN_SETUP_check_partner_name", object = Moveable()}},
                        }},
                        {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, emboss = 0.1, minh = 2.2, r = 0.1}, nodes={
                            {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner", object = UIBox{definition = partner_main, config = {offset = {x=0,y=0}}}}}
                        }}
                    }},
                }},
            }}
        }),
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
                UIBox_button{label = {localize("b_partner_refuse")}, button = "refuse_partner", colour = G.C.FILTER, minw = 4, minh = 0.8, scale = 0.5},
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.45}, nodes={}},
            {n=G.UIT.C, config={align = "cm"}, nodes={
                UIBox_button{label = {localize("b_partner_agree")}, button = "select_partner", func = "select_partner_button", minw = 4, minh = 0.8, scale = 0.5},
            }},
        }},
    }})
    return t
end

G.FUNCS.change_viewed_partner = function(args)
    if not args or not args.cycle_config then return end
    local c = G.partner_area:remove_card(G.partner_area.cards[1])
    c:remove()
    c = nil
    local center = G.P_CENTER_POOLS["Partner"][args.cycle_config.current_option]
    local card = Card(G.partner_area.T.x+G.partner_area.T.w/2-G.CARD_W*23/71, G.partner_area.T.y+G.partner_area.T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
    --card.sticker = get_joker_win_sticker(center)
    card.states.hover.can = false
    G.partner_area:emplace(card)
    G.GAME.viewed_partner = center
    G.PROFILES[G.SETTINGS.profile].MEMORY.partner = args.cycle_config.current_option
end

G.FUNCS.RUN_SETUP_check_partner_name = function(e)
    if e.config.object and G.GAME.viewed_partner.name ~= e.config.id then
        local partner_name = G.GAME.viewed_partner.unlocked and localize{type = "name_text", set = "Partner", key = G.GAME.viewed_partner.key} or localize("k_locked")
        e.config.object:remove()
        e.config.object = UIBox{
            definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner_name", object = DynaText({string = partner_name, maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}},
            }},
            config = {offset = {x=0,y=0}, align = "cm", parent = e}
        }
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.RUN_SETUP_check_partner = function(e)
    if G.GAME.viewed_partner.name ~= e.config.id then
        local UI_table = G.GAME.viewed_partner.unlocked and generate_card_ui(G.GAME.viewed_partner, nil, nil, "Partner") or generate_card_ui(G.GAME.viewed_partner, nil, nil, "Locked")
        local partner_main = {n=G.UIT.ROOT, config={align = "cm", minw = 3.5, minh = 1.75, id = G.GAME.viewed_partner.name, colour = G.C.CLEAR}, nodes={desc_from_rows(UI_table.main, true, 3.5)}}
        e.config.object:remove() 
        e.config.object = UIBox{
            definition = partner_main,
            config = {offset = {x=0,y=0}, align = "cm", parent = e}
        }
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.refuse_partner = function()
    G.FUNCS.exit_overlay_menu()
    G.GAME.refuse_partner = true
end

G.FUNCS.select_partner_button = function(e)
    if G.GAME.viewed_partner and G.GAME.viewed_partner.unlocked then
        e.config.colour = G.C.GREEN
        e.config.button = "select_partner"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.select_partner = function()
    G.FUNCS.exit_overlay_menu()
    G.E_MANAGER:add_event(Event({func = function()
        G.GAME.selected_partner = G.GAME.viewed_partner.key
        G.GAME.selected_partner_card = Card(G.deck.T.x+G.deck.T.w-G.CARD_W*0.6, G.deck.T.y-G.CARD_H*0.8, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, G.GAME.viewed_partner)
        G.GAME.selected_partner_card:juice_up(0.3, 0.5)
    return true end}))
end

local run_setup_option_ref = G.UIDEF.run_setup_option
function G.UIDEF.run_setup_option(type)
	local t = run_setup_option_ref(type)
	if type == "New Run" then
        t.nodes[#t.nodes].nodes[#t.nodes[#t.nodes].nodes] = {n=G.UIT.C, config={align = "cm", minw = 2.4}, nodes={
            type == "New Run" and create_toggle{col = true, label = localize("k_partner"), label_scale = 0.28, w = 0, scale = 0.7, ref_table = Partner_API.config, ref_value = "enable_partner"} or nil
        }}
	end
	return t
end

-- Galdur Compat
local run_setup_option_new_model_ref = G.UIDEF.run_setup_option_new_model
function G.UIDEF.run_setup_option_new_model(type)
    local t = run_setup_option_new_model_ref(type)
    t.nodes[#t.nodes].nodes[2].nodes[#t.nodes[#t.nodes].nodes[2].nodes+1] = {n=G.UIT.C, config={align = "cm", minw = 2.4}, nodes={
        type == "New Run" and create_toggle{col = true, label = localize("k_partner"), label_scale = 0.28, w = 0, scale = 0.7, ref_table = Partner_API.config, ref_value = "enable_partner"} or nil
    }}
	return t
end

local Game_start_run_ref = Game.start_run
function Game:start_run(args)
    Game_start_run_ref(self, args)
    if not G.GAME.selected_partner and not G.GAME.refuse_partner and Partner_API.config.enable_partner then
        G.E_MANAGER:add_event(Event({func = function()
            G.FUNCS.run_setup_partners_option()
        return true end}))
    elseif G.GAME.selected_partner then
        G.E_MANAGER:add_event(Event({func = function()
            local center = nil
            for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
                if v.key == G.GAME.selected_partner then center = v end
            end
            G.GAME.selected_partner_card = Card(G.deck.T.x+G.deck.T.w-G.CARD_W*0.6, G.deck.T.y-G.CARD_H*0.8, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
            G.GAME.selected_partner_card:juice_up(0.3, 0.5)
            if G.GAME.selected_partner_table then
                for k, v in pairs(G.GAME.selected_partner_table) do
                    G.GAME.selected_partner_card.ability.extra[k] = v
                end
                G.GAME.selected_partner_table = nil
            end
        return true end}))
    end
end

-- Hook Page

local save_run_ref = save_run
function save_run()
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability then
        G.GAME.selected_partner_table = G.GAME.selected_partner_table or {}
        for k, v in pairs(G.GAME.selected_partner_card.ability.extra) do
            G.GAME.selected_partner_table[k] = v
        end
    end
    save_run_ref()
end

local Card_click_ref = Card.click
function Card:click()
    Card_click_ref(self)
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card == self and not G.GAME.partner_click_deal then
        self:remove_partner_speech_bubble()
        G.GAME.selected_partner_card:calculate_partner({partner_click = true})
    end
end

-- Talisman Compat
to_big = to_big or function(a)
    return a
end

to_number = to_number or function(a)
    return a
end

function Card:calculate_partner(context)
    if not context then return end
    local obj = self.config.center
    if self.ability.set == "Partner" and obj.calculate and type(obj.calculate) == "function" then
        local ret = obj:calculate(self, context)
        self:general_partner_speech(context)
        if ret then return ret end
    end
end

function Card:general_partner_speech(context)
    if context.partner_setting_blind and G.GAME.round == 1 then
        G.E_MANAGER:add_event(Event({func = function()
            local quip_key = (self.ability.extra and self.ability.extra.quip_key ~= nil and self.ability.extra.quip_key.."_" ) or ""
            self:add_partner_speech_bubble("pnr_"..quip_key..math.random(1,6))
            self:partner_say_stuff(5)
        return true end}))
    end
    if context.partner_setting_blind and context.blind.boss and G.GAME.round_resets.ante == 8 then
        G.E_MANAGER:add_event(Event({func = function()
            self:add_partner_speech_bubble("dq_1")
            self:partner_say_stuff(5)
        return true end}))
    end
end

function Card:calculate_partner_cash()
    local obj = self.config.center
    if self.ability.set == "Partner" and obj.calculate_cash and type(obj.calculate_cash) == "function" then
        local ret = obj:calculate_cash(self)
        if ret then return ret end
    end
end

local SMODS_calculate_repetitions_ref = SMODS.calculate_repetitions
SMODS.calculate_repetitions = function(card, context, reps)
    local reps = SMODS_calculate_repetitions_ref(card, context, reps)
    if G.GAME.selected_partner_card then
        local ret = G.GAME.selected_partner_card:calculate_partner(context)
        if ret then
            SMODS.insert_repetitions(reps, ret, card)
        end
    end
    return reps
end

local SMODS_calculate_card_areas_ref = SMODS.calculate_card_areas
function SMODS.calculate_card_areas(_type, context, return_table, args)
    local flags = SMODS_calculate_card_areas_ref(_type, context, return_table, args)
    if G.GAME.selected_partner_card then
        if _type == "individual" and args and args.main_scoring then
            local ret = G.GAME.selected_partner_card:calculate_partner(context)
            if ret then
                return_table[#return_table+1] = {individual = ret}
            end
        end
    end
    return flags
end

-- Localization Page

function Partner_API.process_loc_text()
    G.localization.descriptions.Partner = G.localization.descriptions.Partner or {}
end

-- Atlas Page

SMODS.Atlas{
    key = "modicon",   
    px = 34,
    py = 34,
    path = "icon.png"
}

SMODS.Atlas{
    key = "Partner",
    px = 46,
    py = 58,
    path = "Partners.png"
}

-- Register Page

Partner_API.Partner{
    key = "joker",
    name = "Joker Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_joker", chips = 0, chip_mod = 2}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_joker")) then benefits = 2 end
        return { vars = {card.ability.extra.chips, card.ability.extra.chip_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_main and card.ability.extra.chips >= 1 then
            return {
                message = localize{type = "variable", key = "a_chips", vars = {card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
        if context.partner_before then
            local benefits = 1
            if next(SMODS.find_card("j_joker")) then benefits = 2 end
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.CHIPS})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_joker" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "mime",
    name = "Mime Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_mime", repetitions = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_mime")) then benefits = 2 end
        return { vars = {card.ability.extra.repetitions*benefits} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.other_card and G.hand.cards[1] and context.other_card == G.hand.cards[1] and next(context.card_effects[1]) then
            local benefits = 1
            if next(SMODS.find_card("j_mime")) then benefits = 2 end
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra.repetitions*benefits,
                card = card
            }
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_mime" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "raised_fist",
    name = "Fist Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_raised_fist", mult = 1, mult_mod = 0.5}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.other_card and G.hand.cards[1] and context.poker_hands and next(context.poker_hands["Pair"]) then
            local min_id = 15
            local raised_card = nil
            for i = 1, #G.hand.cards do
                if min_id >= G.hand.cards[i].base.id and not SMODS.has_no_rank(G.hand.cards[i]) then
                    min_id = G.hand.cards[i].base.id
                    raised_card = G.hand.cards[i]
                end
            end
            if context.other_card == raised_card then
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED,
                        card = card,
                    }
                else
                    return {
                        mult = card.ability.extra.mult,
                        card = card
                    }
                end
            end
        end
        if context.partner_before and context.poker_hands and next(context.poker_hands["Pair"]) then
            local benefits = 1
            if next(SMODS.find_card("j_raised_fist")) then benefits = 2 end
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MULT})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_raised_fist" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "egg",
    name = "Egg Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_egg", sell_cost_mod = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_egg")) then benefits = 2 end
        return { vars = {card.ability.extra.sell_cost_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_end_of_round then
            local benefits = 1
            if next(SMODS.find_card("j_egg")) then benefits = 2 end
            for k, v in ipairs(G.jokers.cards) do
                v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.sell_cost_mod*benefits
                v:set_cost()
            end
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_val_up"), colour = G.C.MONEY})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_egg" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "burglar",
    name = "Burglar Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_burglar", hands_played_mod = 2}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_burglar")) then benefits = 2 end
        return { vars = {card.ability.extra.hands_played_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_setting_blind and context.blind.boss then
            local benefits = 1
            if next(SMODS.find_card("j_burglar")) then benefits = 2 end
            G.E_MANAGER:add_event(Event({func = function()
                ease_hands_played(card.ability.extra.hands_played_mod*benefits)
                card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "variable", key = "a_hands", vars = {card.ability.extra.hands_played_mod*benefits}}})
            return true end}))
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_burglar" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "faceless",
    name = "Faceless Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_faceless", discard_dollars = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_faceless")) then benefits = 2 end
        return { vars = {card.ability.extra.discard_dollars*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_discard and context.other_card and context.other_card:is_face() then
            local benefits = 1
            if next(SMODS.find_card("j_faceless")) then benefits = 2 end
            ease_dollars(card.ability.extra.discard_dollars*benefits)
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("$")..card.ability.extra.discard_dollars*benefits, colour = G.C.MONEY})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_faceless" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "hallucination",
    name = "Hallucination Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_hallucination"}},
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.partner_open_booster then
            G.E_MANAGER:add_event(Event({func = function()
                --thats too unbalanced
                --local _planet = nil
                --for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                    --if v.config.hand_type == G.GAME.last_hand_played then
                        --_planet = v.key
                    --end
                --end
                local _card = create_card("Joker", G.pack_cards, nil, nil, nil, nil, nil, "hal_pnr")
                _card:add_to_deck()
                G.pack_cards:emplace(_card)
                if next(SMODS.find_card("j_hallucination")) then G.GAME.pack_choices = G.GAME.pack_choices + 1 end
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_plus_joker"), colour = G.C.GREEN})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_hallucination" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "fortune_teller",
    name = "Fortune Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_fortune_teller", round = 3, rounds = 3}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.p_arcana_normal_1
        return { vars = {card.ability.extra.rounds, card.ability.extra.round} }
    end,
    calculate = function(self, card, context)
        if context.partner_setting_blind then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds <= 0 then
                card.ability.extra.rounds = 0
            end
        end
        if context.partner_starting_shop and card.ability.extra.rounds <= 0 then
            card.ability.extra.rounds = card.ability.extra.round
            G.E_MANAGER:add_event(Event({func = function()
                local key = "p_arcana_normal_"..(math.random(1, 4))
                if next(SMODS.find_card("j_fortune_teller")) then key = "p_arcana_mega_"..(math.random(1, 2)) end
                local _card = Card(G.shop_booster.T.x+G.shop_booster.T.w/2, G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                create_shop_card_ui(_card, "Booster", G.shop_booster)
                _card:start_materialize()
                G.shop_booster:emplace(_card)
                if next(SMODS.find_card("j_fortune_teller")) then _card.ability.couponed = true; _card:set_cost() end
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_booster"), colour = G.C.PURPLE})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_fortune_teller" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "golden",
    name = "Golden Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_golden", dollars = 2, dollars_mod = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.dollars} }
    end,
    calculate = function(self, card, context)
        if context.partner_skip_blind then
            local benefits = 1
            if next(SMODS.find_card("j_golden")) then benefits = 2 end
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollars_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MONEY})
        end
    end,
    calculate_cash = function(self, card)
        return card.ability.extra.dollars
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_golden" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "baseball",
    name = "Baseball Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_baseball", mult = 3, mult_mod = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult} }
    end,
    calculate = function(self, card, context)
        if context.partner_other_main and context.other_card then
            if context.other_card.ability.set == "Joker" and context.other_card.config.center.rarity == 2 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
        if context.partner_skipping_booster then
            local benefits = 1
            if next(SMODS.find_card("j_baseball")) then benefits = 2 end
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MULT})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_baseball" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "trading",
    name = "Trading Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_trading", discard_dollars = 2}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.discard_dollars} }
    end,
    calculate = function(self, card, context)
        local benefits = 1
        if next(SMODS.find_card("j_trading")) then benefits = 5 end
        if context.partner_discard and G.GAME.current_round.discards_left <= 1 and #context.full_hand <= 1*benefits then
            if context.other_card == context.full_hand[#context.full_hand] then
                ease_dollars(-card.ability.extra.discard_dollars*#context.full_hand)
                card_eval_status_text(card, "dollars", -card.ability.extra.discard_dollars*#context.full_hand)
            end
            return { remove = true }
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_trading" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "flash",
    name = "Flash Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_flash", first_reroll = false}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.partner_reroll_shop and not card.ability.extra.first_reroll then
            for i = 1, #G.shop_jokers.cards do
                if not G.shop_jokers.cards[i].edition and G.shop_jokers.cards[i].ability.set == "Joker" then
                    card.ability.extra.first_reroll = true
                    card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "name_text", key = "e_negative", set = "Edition"}, colour = G.C.DARK_EDITION})
                    G.shop_jokers.cards[i]:set_edition({negative = true}, true)
                    if next(SMODS.find_card("j_flash")) then G.shop_jokers.cards[i].ability.couponed = true; G.shop_jokers.cards[i]:set_cost() end
                    break
                end
            end
        end
        if context.partner_ending_shop and card.ability.extra.first_reroll then
            card.ability.extra.first_reroll = false
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_flash" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "throwback",
    name = "Throwback Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_throwback", xmult = 1, xmult_mod = 0.5, cost = 2}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_throwback")) then benefits = 2 end
        return { vars = {card.ability.extra.xmult, card.ability.extra.xmult_mod*benefits, card.ability.extra.cost} }
    end,
    calculate = function(self, card, context)
        if context.partner_main and card.ability.extra.xmult > 1 then
            return {
                message = localize{type = "variable", key = "a_xmult", vars = {card.ability.extra.xmult}},
                Xmult_mod = card.ability.extra.xmult,
            }
        end
        if context.partner_after and card.ability.extra.xmult > 1 then
            G.E_MANAGER:add_event(Event({func = function()
                card.ability.extra.xmult = 1
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_reset"), colour = G.C.RED})
        end
        if context.partner_click and ((to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) >= to_big(card.ability.extra.cost)) then
            G.GAME.partner_click_deal = true
            local benefits = 1
            if next(SMODS.find_card("j_throwback")) then benefits = 2 end
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod*benefits
            ease_dollars(-card.ability.extra.cost)
            card_eval_status_text(card, "dollars", -card.ability.extra.cost)
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.partner_click_deal = nil
            return true end}))
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_throwback" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "hanging_chad",
    name = "Chad Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_hanging_chad", repetitions = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_hanging_chad")) then benefits = 2 end
        return { vars = {card.ability.extra.repetitions*benefits} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.other_card and context.scoring_hand and context.other_card == context.scoring_hand[1] then
            local benefits = 1
            if next(SMODS.find_card("j_hanging_chad")) then benefits = 2 end
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra.repetitions*benefits,
                card = card
            }
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_hanging_chad" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "bloodstone",
    name = "Blood Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_bloodstone", xmult = 1.5}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_bloodstone")) then benefits = 2 end
        return { vars = {card.ability.extra.xmult*benefits} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.other_card and context.scoring_hand then
            local first_heart = nil
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_suit("Hearts") then
                    first_heart = context.scoring_hand[i]
                    break
                end
            end
            if context.other_card == first_heart then
                local benefits = 1
                if next(SMODS.find_card("j_bloodstone")) then benefits = 2 end
                return {
                    x_mult = card.ability.extra.xmult*benefits,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_bloodstone" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "burnt",
    name = "Burnt Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_burnt", odd = 4, upgrade_mod = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = {""..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odd} }
    end,
    calculate = function(self, card, context)
        if context.partner_pre_discard and pseudorandom("burnt_pnr") < G.GAME.probabilities.normal/card.ability.extra.odd then
            local benefits = 1
            if next(SMODS.find_card("j_burnt")) then benefits = 2 end
            local text, disp_text = G.FUNCS.get_poker_hand_info(context.full_hand)
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex")})
            update_hand_text({sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = localize(text, "poker_hands"), chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level = G.GAME.hands[text].level})
            level_up_hand(card, text, nil, card.ability.extra.upgrade_mod*benefits)
            update_hand_text({sound = "button", volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = "", level = ""})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_burnt" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}
