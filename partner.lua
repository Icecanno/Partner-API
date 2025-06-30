-- Extend Page

Partner_API = SMODS.current_mod

Partner_API.Partner = SMODS.Center:extend{
    unlocked = true,
    discovered = false,
    no_quips = false,
    individual_quips = false,
    config = {},
    link_config = {},
    set = "Partner",
    class_prefix = "pnr",
    required_params = {"key", "atlas", "pos"},
    pre_inject_class = function(self)
        G.P_CENTER_POOLS[self.set] = {}
    end,
    set_card_type_badge = function(self, card, badges)
        local display_info = {localize("k_partner")}
        if self.badges_info and next(self.badges_info) then
            for _, v in pairs(self.badges_info) do
                if localize(v) ~= "ERROR" then
                    display_info[#display_info+1] = localize(v)
                else
                    display_info[#display_info+1] = v
                end
            end
        end
        badges[#badges+1] = create_badge(display_info, G.C.DARK_EDITION, G.C.WHITE)
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        if next(self.link_config) then
            local link_level = nil
            for k, v in pairs(self.link_config) do
                if next(SMODS.find_card(k)) and (not link_level or link_level < v) then
                    link_level = v
                end
            end
            if link_level then
                local main_end = {{n=G.UIT.C, config={align = "bm"}, nodes={
                    {n=G.UIT.O, config={object = DynaText({string = {"<"..localize("k_partner_buffed_level")..link_level..">"}, colours = {G.C.DARK_EDITION}, float = true, scale = 0.3})}},
                }}}
                desc_nodes[#desc_nodes+1] = main_end
            end
        end
    end,

    locked_loc_vars = function(self, info_queue, card)
        if self.unlock_condition.type == "partner_joker_stake" then
            local stake_name = localize{type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[self.unlock_condition.stake].key}
            local joker_name = localize({ type = "name_text", key = self.unlock_condition.joker, set = "Joker" })
            local joker_discovered = G.P_CENTERS[self.unlock_condition.joker].discovered
            return { vars = { stake_name, joker_discovered and joker_name or localize("k_unknown"), colours = {get_stake_col(self.unlock_condition.stake)} }, key="partner_locked_joker_stake" }
        else
            return { }
        end
    end,
    check_for_unlock = function(self, args)
        if self.unlock_condition.type == "partner_joker_stake" then
            if get_joker_win_sticker(G.P_CENTERS[self.unlock_condition.joker], true) >= self.unlock_condition.stake then
                return true
            end
        end
    end,
}

-- Collection Page

Partner_API.custom_collection_tabs = function()
    local tally = 0
    for _, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v:is_unlocked() then
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
            if not center then break end
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
    for i = 1, math.ceil(#G.P_CENTER_POOLS["Partner"] / 8) do
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

function Partner_API.Partner:get_link_level()
    if next(self.link_config) then
        local link_level = nil
        for k, v in pairs(self.link_config) do
            if next(SMODS.find_card(k)) and (not link_level or link_level < v) then
                link_level = v
            end
        end
        return link_level
    end
end

function Partner_API.Partner:is_unlocked()
    return self.unlocked or Partner_API.config.temporary_unlock_all or G.PROFILES[G.SETTINGS.profile].all_unlocked
end

Partner_API.description_loc_vars = function()
    return {background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2, shadow = true}
end

Partner_API.custom_ui = function(nodes)
    local _, description = unpack(nodes)
    local wiki_deepfind = SMODS.deepfind(description, "https://balatromods.miraheze.org/wiki/Partner", true)[1]
    if wiki_deepfind then
        local wiki_link_table = wiki_deepfind.objtree[#wiki_deepfind.objtree-2]
        wiki_link_table.config.button = "open_partner_wiki"
        wiki_link_table.config.tooltip = {text = {localize("b_open_partner_wiki")}}
    end
end

Partner_API.config_tab = function()
    return {n=G.UIT.ROOT, config = {align = "cm", padding = 0.05, colour = G.C.CLEAR}, nodes={
        create_toggle({label = localize("k_enable_partner"), ref_table = Partner_API.config, ref_value = "enable_partner"}),
        create_toggle({label = localize("k_enable_speech_bubble"), ref_table = Partner_API.config, ref_value = "enable_speech_bubble"}),
        create_toggle({label = localize("k_temporary_unlock_all"), ref_table = Partner_API.config, ref_value = "temporary_unlock_all"}),
    }}
end

G.FUNCS.open_partner_wiki = function(e)
    love.system.openURL("https://balatromods.miraheze.org/wiki/Partner")
end

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if _c and _c.set == "Partner" and _c:is_unlocked() and card_type and card_type == "Locked" and (specific_vars and not specific_vars.no_name or not specific_vars) then card_type = "Partner" end
    if _c and _c.set == "Partner" and _c:is_unlocked() and badges then badges.card_type = "Partner" end
    return generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
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
    if card_center.set == "Partner" then
        local title = ret.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].config
        title.object:remove()
        title.object = DynaText({string = {localize("k_partner")}, colours = {G.C.BLUE}, shadow = true, rotate = true, bump = true, pop_in = 0.3, pop_in_rate = 2, scale = 1.2})
    end
    return ret
end

local create_UIBox_notify_alert_ref = create_UIBox_notify_alert
function create_UIBox_notify_alert(_achievement, _type)
    local ret = create_UIBox_notify_alert_ref(_achievement, _type)
    if _type == "Partner" then
        local title = ret.nodes[1].nodes[1].nodes[2].nodes[1].nodes[1].config
        title.text = localize("k_partner")
    end
    return ret
end

function Card:add_partner_speech_bubble(forced_key)
    if not Partner_API.config.enable_speech_bubble then return end
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
    local hold_time = (G.SETTINGS.GAMESPEED*4) or 4
    G.E_MANAGER:add_event(Event({trigger = "after", delay = hold_time, blockable = false, blocking = false, func = function()
        self:remove_partner_speech_bubble()
    return true end}))
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
    if not Partner_API.config.enable_speech_bubble then return end
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
    G.GAME.viewed_partner = G.P_CENTER_POOLS["Partner"][G.PROFILES[G.SETTINGS.profile].MEMORY.partner] or G.P_CENTER_POOLS["Partner"][1]
    local partner_selection, partner_selection_cycle = create_partner_selection()
    G.partner_area = CardArea(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W*46/71, G.CARD_H*58/95, {card_limit = 2, type = "title", highlight_limit = 0})
    local center = G.GAME.viewed_partner
    local card = Card(G.partner_area.T.x+G.partner_area.T.w/2-G.CARD_W*23/71, G.partner_area.T.y+G.partner_area.T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
    local minw = 3
    local UI_table = G.GAME.viewed_partner:is_unlocked() and generate_card_ui(G.GAME.viewed_partner, nil, nil, "Partner") or generate_card_ui(G.GAME.viewed_partner, nil, nil, "Locked")
    local partner_main = {n=G.UIT.ROOT, config={align = "cm", minw = minw, minh = 2, id = G.GAME.viewed_partner.name, colour = G.C.CLEAR}, nodes={desc_from_rows(UI_table.main, true, minw-0.2)}}
    --card.sticker = get_joker_win_sticker(center)
    card.states.hover.can = false
    G.partner_area:emplace(card)
    local t = create_UIBox_generic_options({no_back = true, contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.15, r = 0.1, colour = G.C.L_BLACK}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                partner_selection,
                partner_selection_cycle
            }},
            {n=G.UIT.C, config={align = "tm", minw = 3, minh = 1, r = 0.1, colour = G.C.BLACK, padding = 0.15, emboss = 0.05}, nodes={
                {n=G.UIT.R, config={align = "cm", emboss = 0.1, r = 0.1, minw = 2, minh = 0.5}, nodes={
                    {n=G.UIT.O, config={id = nil, func = "RUN_SETUP_check_partner_name", object = Moveable()}},
                }},
                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                    {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner_card", object = G.partner_area}},
                }},
                {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, emboss = 0.1, r = 0.1}, nodes={
                    {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner", object = UIBox{definition = partner_main, config = {offset = {x=0,y=0}}}}}
                }}
            }},
        }},
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.C, config={minw = 2.72, minh = 0.8, r = 0.1, hover = true, button = "skip_partner", colour = G.C.FILTER, align = "cm", emboss = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize("b_partner_skip"), scale = 0.5, colour = G.C.WHITE}}
                }},
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.2}, nodes={}},
            {n=G.UIT.C, config={minw = 2.72, minh = 0.8, r = 0.1, hover = true, button = "random_partner", colour = G.C.BLUE, align = "cm", emboss = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize("b_partner_random"), scale = 0.5, colour = G.C.WHITE}}
                }},
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.2}, nodes={}},
            {n=G.UIT.C, config={minw = 3.33, minh = 0.8, r = 0.1, hover = true, button = "select_partner", func = "select_partner_button", align = "cm", emboss = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize("b_partner_agree"), scale = 0.5, colour = G.C.WHITE}}
                }},
            }},
        }},
    }})
    return t
end

function create_partner_selection()
    local partner_tables = {}
    G.partner_selection = {}
    for i = 1, 2 do
        local row = {n=G.UIT.R, config={colour = G.C.LIGHT}, nodes={}}
        for j = 1, 4 do
            G.partner_selection[j+(i-1)*4] = CardArea(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W*46/71, G.CARD_H*58/95, {card_limit = 2, type = "title", highlight_limit = 0})
            table.insert(row.nodes, {n=G.UIT.O, config={object = G.partner_selection[j+(i-1)*4]}})
        end
        table.insert(partner_tables, row)
    end
    local partner_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS["Partner"]/(#G.partner_selection)) do
        table.insert(partner_options, localize("k_page").." "..tostring(i).."/"..tostring(math.ceil(#G.P_CENTER_POOLS["Partner"]/(#G.partner_selection))))
    end
    local viewed_partner = 1
    for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v.name == G.GAME.viewed_partner.name then
            viewed_partner = math.ceil(k/(#G.partner_selection))
            break
        end
    end
    for i = 1, #G.partner_selection do
        local center = G.P_CENTER_POOLS["Partner"][i+(#G.partner_selection*(viewed_partner-1))]
        if not center then break end
        local card = Card(G.partner_selection[i].T.x+G.partner_selection[i].T.w/2-G.CARD_W*23/71, G.partner_selection[i].T.y+G.partner_selection[i].T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, empty, center)
        card.no_ui = true; card.config.card.no_ui = true
        card.ability.fake_partner = true
        G.partner_selection[i]:emplace(card)
    end
    local t, tt = {n=G.UIT.R, config={align = "cm", r = 0.1, minh = 3.6, colour = G.C.BLACK, emboss = 0.05}, nodes=partner_tables},
    {n=G.UIT.R, config={align = "cm"}, nodes={
        create_option_cycle({options = partner_options, w = 2.5, cycle_shoulders = true, opt_callback = "your_selection_partner_page", current_option = viewed_partner, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = "wide"}})
    }}
    return t, tt
end

G.FUNCS.your_selection_partner_page = function(args)
    if not args or not args.cycle_config then return end
    for j = 1, #G.partner_selection do
        for i = #G.partner_selection[j].cards, 1, -1 do
            local c = G.partner_selection[j]:remove_card(G.partner_selection[j].cards[i])
            c:remove()
            c = nil
        end
    end
    for j = 1, #G.partner_selection do
        local center = G.P_CENTER_POOLS["Partner"][j+(#G.partner_selection*(args.cycle_config.current_option-1))]
        if not center then break end
        local card = Card(G.partner_selection[j].T.x+G.partner_selection[j].T.w/2-G.CARD_W*23/71, G.partner_selection[j].T.y+G.partner_selection[j].T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
        card.no_ui = true; card.config.card.no_ui = true
        card.ability.fake_partner = true
        G.partner_selection[j]:emplace(card)
    end
end

G.FUNCS.RUN_SETUP_check_partner_card = function(e)
    if e.config.object and G.GAME.viewed_partner.name ~= e.config.id then
        local c = G.partner_area:remove_card(G.partner_area.cards[1])
        c:remove()
        c = nil
        local center = G.GAME.viewed_partner
        local card = Card(G.partner_area.T.x+G.partner_area.T.w/2-G.CARD_W*23/71, G.partner_area.T.y+G.partner_area.T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
        card.states.hover.can = false
        G.partner_area:emplace(card)
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.RUN_SETUP_check_partner_name = function(e)
    if e.config.object and G.GAME.viewed_partner.name ~= e.config.id then
        local partner_name = G.GAME.viewed_partner:is_unlocked() and localize{type = "name_text", set = "Partner", key = G.GAME.viewed_partner.key} or localize("k_locked")
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
        local minw = 3
        local UI_table = G.GAME.viewed_partner:is_unlocked() and generate_card_ui(G.GAME.viewed_partner, nil, nil, "Partner") or generate_card_ui(G.GAME.viewed_partner, nil, nil, "Locked")
        local partner_main = {n=G.UIT.ROOT, config={align = "cm", minw = minw, minh = 2, id = G.GAME.viewed_partner.name, colour = G.C.CLEAR}, nodes={desc_from_rows(UI_table.main, true, minw-0.2)}}
        e.config.object:remove() 
        e.config.object = UIBox{
            definition = partner_main,
            config = {offset = {x=0,y=0}, align = "cm", parent = e}
        }
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.skip_partner = function()
    G.FUNCS.exit_overlay_menu()
    G.GAME.skip_partner = true
end

G.FUNCS.random_partner = function()
    local center = pseudorandom_element(G.P_CENTER_POOLS["Partner"], pseudoseed(os.time()))
    G.GAME.viewed_partner = center
    for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v == G.GAME.viewed_partner then
            G.PROFILES[G.SETTINGS.profile].MEMORY.partner = k
        end
    end
end

G.FUNCS.select_partner_button = function(e)
    if G.GAME.viewed_partner and G.GAME.viewed_partner:is_unlocked() then
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
        G.GAME.selected_partner_card = Card(G.deck.T.x+G.deck.T.w-G.CARD_W*0.6, G.deck.T.y-G.CARD_H*1.6, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, G.GAME.viewed_partner)
        G.GAME.selected_partner_card:juice_up(0.3, 0.5)
        local ret = G.GAME.selected_partner_card:calculate_partner_begin()
        if ret then SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card) end
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
    local any_unlocked = false
    for _, v in ipairs(G.P_CENTER_POOLS.Partner) do 
        if v.unlocked then
            any_unlocked = true
            break
        end
    end
    if any_unlocked and not G.GAME.selected_partner and not G.GAME.skip_partner and Partner_API.config.enable_partner then
        G.E_MANAGER:add_event(Event({func = function()
            G.FUNCS.run_setup_partners_option()
        return true end}))
    elseif G.GAME.selected_partner then
        G.E_MANAGER:add_event(Event({func = function()
            local center = nil
            for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
                if v.key == G.GAME.selected_partner then center = v end
            end
            G.GAME.selected_partner_card = Card(G.deck.T.x+G.deck.T.w-G.CARD_W*0.6, G.deck.T.y-G.CARD_H*1.6, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
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

-- Controller Page

local Controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    Controller_queue_R_cursor_press_ref(self, x, y)
    if self.locks.frame then return end
    self.partner_R_cursor_queue = {x = x, y = y}
end

local Controller_update_ref = Controller.update
function Controller:update(dt)
    Controller_update_ref(self, dt)
    if self.partner_R_cursor_queue then 
        self:partner_R_cursor_press(self.partner_R_cursor_queue.x, self.partner_R_cursor_queue.y)
        self.partner_R_cursor_queue = nil
    end
    if not self.cursor_up.partner_R_handled then
        if self.cursor_down.partner_R_target then 
            if (not self.cursor_down.partner_R_target.click_timeout or self.cursor_down.partner_R_target.click_timeout*G.SPEEDFACTOR > self.cursor_up.partner_R_time - self.cursor_down.partner_R_time) then
                if Vector_Dist(self.cursor_down.partner_R_T, self.cursor_up.partner_R_T) < G.MIN_CLICK_DIST then 
                    if self.cursor_down.partner_R_target.states.click.can then
                        self.clicked.partner_R_target = self.cursor_down.partner_R_target
                        self.clicked.partner_R_handled = false
                    end
                end
            end
        end
        self.cursor_up.partner_R_handled = true
    end
    if not self.clicked.partner_R_handled then
        if self.clicked.partner_R_target then
            self.clicked.partner_R_target:partner_R_click()
            self.clicked.partner_R_handled = true
        end
    end
    if G.GAME and G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability and self.cursor_hover.target and self.cursor_hover.target == G.GAME.selected_partner_card then
        if not G.GAME.partner_pet_dist or not G.GAME.partner_pet_dist_T then
            G.GAME.partner_pet_dist = 0
            G.GAME.partner_pet_dist_T = {x = self.cursor_position.x, y = self.cursor_position.y}
        elseif G.GAME.partner_pet_dist and G.GAME.partner_pet_dist_T then
            G.GAME.partner_pet_dist = G.GAME.partner_pet_dist + Vector_Dist(G.GAME.partner_pet_dist_T, {x = self.cursor_position.x, y = self.cursor_position.y})
            G.GAME.partner_pet_dist_T = {x = self.cursor_position.x, y = self.cursor_position.y}
            if G.GAME.partner_pet_dist > 500 and not G.GAME.partner_pet_deal then
                G.GAME.partner_pet_deal = true
                local ret = G.GAME.selected_partner_card:calculate_partner({partner_pet = true})
                if ret then
                    SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
                end
                G.E_MANAGER:add_event(Event({func = function()
                    G.GAME.partner_pet_dist = 0
                    G.GAME.partner_pet_deal = nil
                return true end}))
            end
        end
    elseif not self.cursor_hover.target or self.cursor_hover.target and self.cursor_hover.target ~= G.GAME.selected_partner_card and (G.GAME.partner_pet_dist or G.GAME.partner_pet_dist_T) then
        G.GAME.partner_pet_dist = nil
        G.GAME.partner_pet_dist_T = nil
    end
end

function Controller:partner_R_cursor_press(x, y)
    if ((self.locked) and (not G.SETTINGS.paused or G.screenwipe)) or (self.locks.frame) then return end
    local x = x or self.cursor_position.x
    local y = y or self.cursor_position.y
    self.cursor_down.partner_R_T = {x = x/(G.TILESCALE*G.TILESIZE), y = y/(G.TILESCALE*G.TILESIZE)}
    self.cursor_down.partner_R_time = G.TIMERS.TOTAL
    self.cursor_down.partner_R_target = nil
    local press_node = (self.HID.touch and self.cursor_hover.target) or self.hovering.target or self.focused.target
    if press_node then 
        self.cursor_down.partner_R_target = press_node.states.click.can and press_node or press_node:can_drag() or nil
    end
    if self.cursor_down.partner_R_target == nil then
        self.cursor_down.partner_R_target = G.ROOM
    end
end

local love_mousereleased_ref = love.mousereleased
function love.mousereleased(x, y, button)
    love_mousereleased_ref(x, y, button)
    if button == 2 then G.CONTROLLER:partner_R_cursor_release(x, y) end
end

local Controller_button_release_update_ref = Controller.button_release_update
function Controller:button_release_update(button, dt)
    Controller_button_release_update_ref(self, button, dt)
    if not self.held_button_times[button] then return end
    if button == "b" then
        self:partner_R_cursor_release()
    end
end

function Controller:partner_R_cursor_release(x, y)
    if ((self.locked) and (not G.SETTINGS.paused or G.screenwipe)) or (self.locks.frame) then return end
    local x = x or self.cursor_position.x
    local y = y or self.cursor_position.y
    self.cursor_up.partner_R_T = {x = x/(G.TILESCALE*G.TILESIZE), y = y/(G.TILESCALE*G.TILESIZE)}
    self.cursor_up.partner_R_time = G.TIMERS.TOTAL
    self.cursor_up.partner_R_handled = false
end

function Node:partner_R_click() end

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
    if self.ability.set == "Partner" and self.ability.fake_partner then
        G.GAME.viewed_partner = self.config.center
        for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
            if v == G.GAME.viewed_partner then
                G.PROFILES[G.SETTINGS.profile].MEMORY.partner = k
            end
        end
    end
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability and G.GAME.selected_partner_card == self then
        if self.children.speech_bubble then
            self:remove_partner_speech_bubble()
        elseif not G.GAME.partner_click_deal then
            G.GAME.partner_click_deal = true
            local ret = G.GAME.selected_partner_card:calculate_partner({partner_click = true})
            if ret then
                SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
            end
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.partner_click_deal = nil
            return true end}))
        end
    end
end

function Card:partner_R_click()
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability and G.GAME.selected_partner_card == self then
        if not G.GAME.partner_R_click_deal then
            G.GAME.partner_R_click_deal = true
            local ret = G.GAME.selected_partner_card:calculate_partner({partner_R_click = true})
            if ret then
                SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
            end
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.partner_R_click_deal = nil
            return true end}))
        end
    end
end

local playing_card_joker_effects_ref = playing_card_joker_effects
function playing_card_joker_effects(cards)
    playing_card_joker_effects_ref(cards)
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability then
        local ret = G.GAME.selected_partner_card:calculate_partner({playing_card_added = true, cards = cards})
        if ret and ret.duplication then
            for k, v in ipairs(ret) do
                SMODS.trigger_effects({{individual = v}}, G.GAME.selected_partner_card)
            end
        elseif ret then
            SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
        end
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
    if not context or self.config.center.no_quips then return end
    if context.setting_blind and G.GAME.round == 1 then
        if self.config.center.individual_quips then
            G.E_MANAGER:add_event(Event({func = function()
                local max_quips = 0
                for k, v in pairs(G.localization.misc.quips) do
                    if string.find(k, self.config.center.key) then
                        max_quips = max_quips + 1
                    end
                end
                self:add_partner_speech_bubble(self.config.center.key.."_"..math.random(1, max_quips))
                self:partner_say_stuff(5)
            return true end}))
        else
            G.E_MANAGER:add_event(Event({func = function()
                self:add_partner_speech_bubble("pnr_"..math.random(1,6))
                self:partner_say_stuff(5)
            return true end}))
        end
    end
    if context.setting_blind and context.blind.boss and G.GAME.round_resets.ante == G.GAME.win_ante then
        if self.config.center.individual_quips then
            G.E_MANAGER:add_event(Event({func = function()
                local max_quips = 0
                for k, v in pairs(G.localization.misc.quips) do
                    if string.find(k, self.config.center.key) then
                        max_quips = max_quips + 1
                    end
                end
                self:add_partner_speech_bubble(self.config.center.key.."_"..math.random(1, max_quips))
                self:partner_say_stuff(5)
            return true end}))
        else
            G.E_MANAGER:add_event(Event({func = function()
                self:add_partner_speech_bubble("dq_1")
                self:partner_say_stuff(5)
            return true end}))
        end
    end
end

function Card:calculate_partner_cash()
    local obj = self.config.center
    if self.ability.set == "Partner" and obj.calculate_cash and type(obj.calculate_cash) == "function" then
        local ret = obj:calculate_cash(self)
        if ret then return ret end
    end
end

function Card:calculate_partner_begin()
    local obj = self.config.center
    if self.ability.set == "Partner" and obj.calculate_begin and type(obj.calculate_begin) == "function" then
        local ret = obj:calculate_begin(self)
        if ret then return ret end
    end
end

local SMODS_calculate_repetitions_ref = SMODS.calculate_repetitions
SMODS.calculate_repetitions = function(card, context, reps)
    local reps = SMODS_calculate_repetitions_ref(card, context, reps)
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability then
        local ret = G.GAME.selected_partner_card:calculate_partner(context)
        if ret and ret.duplication then
            for k, v in ipairs(ret) do
                SMODS.insert_repetitions(reps, v, card)
            end
        elseif ret then
            SMODS.insert_repetitions(reps, ret, card)
        end
    end
    return reps
end

local SMODS_calculate_card_areas_ref = SMODS.calculate_card_areas
function SMODS.calculate_card_areas(_type, context, return_table, args)
    local flags = SMODS_calculate_card_areas_ref(_type, context, return_table, args)
    if _type == "individual" then
        if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability then
            local ret = G.GAME.selected_partner_card:calculate_partner(context)
            if ret and ret.duplication then
                for k, v in ipairs(ret) do
                    if return_table then
                        return_table[#return_table+1] = {individual = v}
                    else
                        local f = SMODS.trigger_effects({{individual = v}}, G.GAME.selected_partner_card)
                        for k, v in pairs(f) do flags[k] = v end
                    end
                end
            elseif ret then
                if return_table then
                    return_table[#return_table+1] = {individual = ret}
                else
                    local f = SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
                    for k, v in pairs(f) do flags[k] = v end
                end
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
    key = "jimbo",
    name = "Jimbo Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_joker"},
    discovered = true,
    pos = {x = 0, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {chips = 0, chip_mod = 3}},
    link_config = {j_joker = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.chips, card.ability.extra.chip_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.chips >= 1 then
            return {
                message = localize{type = "variable", key = "a_chips", vars = {card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
        if context.before then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.CHIPS})
        end
    end,
}

Partner_API.Partner{
    key = "mute",
    name = "Mute Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_mime"},
    discovered = true,
    pos = {x = 1, y = 0},
    loc_txt = {},
    atlas = "Partner",
    individual_quips = true,
    config = {extra = {repetitions = 1}},
    link_config = {j_mime = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        local benefits = 1
        if link_level == 1 then
            key = key.."_"..link_level
            benefits = 2
        end
        return { key = key, vars = {card.ability.extra.repetitions*benefits} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.hand and context.other_card == G.hand.cards[#G.hand.cards] and next(context.card_effects[1]) then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra.repetitions*benefits,
                card = card
            }
        end
    end,
}

Partner_API.Partner{
    key = "unite",
    name = "Unite Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_raised_fist"},
    discovered = true,
    pos = {x = 2, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {x_mult = 1.5}},
    link_config = {j_raised_fist = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 4/3 end
        return { vars = {card.ability.extra.x_mult*benefits} }
    end,
    calculate = function(self, card, context)
        if not context.end_of_round and context.individual and context.cardarea == G.hand then
            local max_id = 1
            local raised_card = nil
            for i = 1, #G.hand.cards do
                if max_id <= G.hand.cards[i].base.id and not SMODS.has_no_rank(G.hand.cards[i]) then
                    max_id = G.hand.cards[i].base.id
                    raised_card = G.hand.cards[i]
                end
            end
            if context.other_card == raised_card then
                local link_level = self:get_link_level()
                local benefits = 1
                if link_level == 1 then benefits = 4/3 end
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED,
                        card = card,
                    }
                else
                    return {
                        x_mult = card.ability.extra.x_mult*benefits,
                        card = card
                    }
                end
            end
        end
    end,
}

Partner_API.Partner{
    key = "hatch",
    name = "Hatch Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_egg"},
    discovered = true,
    pos = {x = 3, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {sell_cost_mod = 1}},
    link_config = {j_egg = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.sell_cost_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            for k, v in ipairs(G.jokers.cards) do
                v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.sell_cost_mod*benefits
                v:set_cost()
            end
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_val_up"), colour = G.C.MONEY})
        end
    end,
}

Partner_API.Partner{
    key = "steal",
    name = "Steal Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_burglar"},
    discovered = true,
    pos = {x = 1, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {hands_played_mod = 2}},
    link_config = {j_burglar = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {card.ability.extra.hands_played_mod} }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local link_level = self:get_link_level()
            if context.blind.boss or link_level == 1 then
                if link_level == 1 then
                    G.E_MANAGER:add_event(Event({func = function()
                        ease_discard(card.ability.extra.hands_played_mod)
                        card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "variable", key = "a_discards", vars = {card.ability.extra.hands_played_mod}}})
                    return true end}))
                else
                    G.E_MANAGER:add_event(Event({func = function()
                        ease_hands_played(card.ability.extra.hands_played_mod)
                        card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "variable", key = "a_hands", vars = {card.ability.extra.hands_played_mod}}})
                    return true end}))
                end
            end
        end
    end,
}

Partner_API.Partner{
    key = "pale",
    name = "Pale Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_faceless"},
    discovered = true,
    pos = {x = 2, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {discard_requires = 9, current_requires = 9, discard_dollars = 6}},
    link_config = {j_faceless = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.discard_requires, card.ability.extra.current_requires, card.ability.extra.discard_dollars*benefits} }
    end,
    calculate = function(self, card, context)
        if context.discard and context.other_card:is_face() then
            if card.ability.extra.current_requires <= 1 then
                local link_level = self:get_link_level()
                local benefits = 1
                if link_level == 1 then benefits = 2 end
                card.ability.extra.current_requires = card.ability.extra.discard_requires
                ease_dollars(card.ability.extra.discard_dollars*benefits)
                card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("$")..card.ability.extra.discard_dollars*benefits, colour = G.C.MONEY})
            else
                card.ability.extra.current_requires = card.ability.extra.current_requires - 1
            end
        end
    end,
}

Partner_API.Partner{
    key = "penalty",
    name = "Penalty Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_red_card"},
    discovered = true,
    pos = {x = 4, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {}},
    link_config = {j_red_card = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {} }
    end,
    calculate = function(self, card, context)
        if context.skipping_booster and context.booster.cost >= 1 then
            local link_level = self:get_link_level()
            local benefits = 2
            if link_level == 1 then benefits = 1 end
            ease_dollars(math.ceil(context.booster.cost/benefits))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("$")..math.ceil(context.booster.cost/benefits), colour = G.C.MONEY})
        end
    end,
}

Partner_API.Partner{
    key = "fantasy",
    name = "Fantasy Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_hallucination"},
    discovered = true,
    pos = {x = 0, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {odd = 4}},
    link_config = {j_hallucination = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {""..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odd/benefits} }
    end,
    calculate = function(self, card, context)
        if context.open_booster and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            if pseudorandom("fan_pnr") < G.GAME.probabilities.normal/(card.ability.extra.odd/benefits) then
                G.E_MANAGER:add_event(Event({func = function()
                    local _card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, nil, "fan_pnr")
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                    G.GAME.consumeable_buffer = 0
                return true end}))
                card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_plus_spectral"), colour = G.C.SECONDARY_SET.Spectral})
            end
        end
    end,
}

Partner_API.Partner{
    key = "oracle",
    name = "Oracle Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_fortune_teller"},
    discovered = true,
    pos = {x = 3, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {require_rounds = 3, current_rounds = 3}},
    link_config = {j_fortune_teller = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        info_queue[#info_queue+1] = G.P_CENTERS.p_arcana_normal_1
        return { key = key, vars = {card.ability.extra.require_rounds, card.ability.extra.current_rounds} }
    end,
    calculate = function(self, card, context)
        if context.starting_shop then
            local link_level = self:get_link_level()
            if card.ability.extra.current_rounds <= 1 or link_level == 1 then
                card.ability.extra.current_rounds = card.ability.extra.require_rounds
                G.E_MANAGER:add_event(Event({func = function()
                    local key = "p_arcana_normal_"..(math.random(1, 4))
                    local _card = Card(G.shop_booster.T.x+G.shop_booster.T.w/2, G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(_card, "Booster", G.shop_booster)
                    _card:start_materialize()
                    G.shop_booster:emplace(_card)
                    _card.ability.couponed = true
                    _card:set_cost()
                return true end}))
                card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_booster"), colour = G.C.PURPLE})
            else
                card.ability.extra.current_rounds = card.ability.extra.current_rounds - 1
            end
        end
    end,
}

Partner_API.Partner{
    key = "finesse",
    name = "Finesse Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_juggler"},
    discovered = true,
    pos = {x = 2, y = 4},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {hand_size = 1}},
    link_config = {j_juggler = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {card.ability.extra.hand_size} }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local link_level = self:get_link_level()
            if (#G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit) or link_level == 1 then
                G.E_MANAGER:add_event(Event({func = function()
                    G.hand:change_size(card.ability.extra.hand_size)
                    G.GAME.round_resets.temp_handsize = (G.GAME.round_resets.temp_handsize or 0) + card.ability.extra.hand_size
                    card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "variable", key = "a_handsize", vars = {card.ability.extra.hand_size}}})
                return true end}))
            end
        end
    end,
}

Partner_API.Partner{
    key = "gilded",
    name = "Gilded Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_golden"},
    discovered = true,
    pos = {x = 0, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {dollars = 1, dollars_mod = 1}},
    link_config = {j_golden = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.dollars, card.ability.extra.dollars_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and G.GAME.blind.boss then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollars_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MONEY})
        end
    end,
    calculate_cash = function(self, card)
        return card.ability.extra.dollars
    end,
}

Partner_API.Partner{
    key = "batter",
    name = "Batter Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_baseball"},
    discovered = true,
    pos = {x = 1, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {mult = 6}},
    link_config = {j_baseball = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 3.5 end
        return { vars = {card.ability.extra.mult*benefits} }
    end,
    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.config.center.rarity == 2 then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 3.5 end
            return {
                mult = card.ability.extra.mult*benefits,
                card = card
            }
        end
    end,
}

Partner_API.Partner{
    key = "bargain",
    name = "Bargain Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_trading"},
    discovered = true,
    pos = {x = 2, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {discard_dollars = 2}},
    link_config = {j_trading = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {card.ability.extra.discard_dollars} }
    end,
    calculate = function(self, card, context)
        if context.discard and G.GAME.current_round.discards_left <= 1 then
            local link_level = self:get_link_level()
            if #context.full_hand <= 1 or (link_level == 1 and #context.full_hand <= 2) then
                if context.other_card == context.full_hand[#context.full_hand] then
                    if link_level == 1 then
                        card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_partner_destroyed"), colour = G.C.RED})
                    else
                        ease_dollars(-card.ability.extra.discard_dollars)
                        card_eval_status_text(card, "dollars", -card.ability.extra.discard_dollars)
                    end
                end
                return { remove = true }
            end
        end
    end,
}

Partner_API.Partner{
    key = "memory",
    name = "Memory Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_flash"},
    discovered = true,
    pos = {x = 3, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {first_reroll = false}},
    link_config = {j_flash = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        info_queue[#info_queue+1] = {key = "memory_negative", set = "Other", vars = {1}}
        return { key = key, vars = {} }
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not card.ability.extra.first_reroll then
            for i = 1, #G.shop_jokers.cards do
                if not G.shop_jokers.cards[i].edition then
                    card.ability.extra.first_reroll = true
                    card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "name_text", key = "memory_negative", set = "Other"}, colour = G.C.DARK_EDITION})
                    G.shop_jokers.cards[i]:set_edition({negative = true}, true)
                    local link_level = self:get_link_level()
                    if link_level == 1 then
                        G.shop_jokers.cards[i].ability.couponed = true
                        G.shop_jokers.cards[i]:set_cost()
                    end
                    break
                end
            end
        end
        if context.ending_shop and card.ability.extra.first_reroll then
            card.ability.extra.first_reroll = false
        end
    end,
}

Partner_API.Partner{
    key = "stoke",
    name = "Stoke Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_campfire"},
    discovered = true,
    pos = {x = 4, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {xmult = 1, xmult_mod = 0.5, cost = 2}},
    link_config = {j_campfire = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.xmult, card.ability.extra.xmult_mod*benefits, card.ability.extra.cost} }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.xmult > 1 then
            return {
                message = localize{type = "variable", key = "a_xmult", vars = {card.ability.extra.xmult}},
                Xmult_mod = card.ability.extra.xmult,
            }
        end
        if context.after and card.ability.extra.xmult > 1 then
            G.E_MANAGER:add_event(Event({func = function()
                card.ability.extra.xmult = 1
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_reset"), colour = G.C.RED})
        end
        if context.partner_click and ((to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) >= to_big(card.ability.extra.cost)) then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod*benefits
            ease_dollars(-card.ability.extra.cost)
            card_eval_status_text(card, "dollars", -card.ability.extra.cost)
        end
    end,
}

Partner_API.Partner{
    key = "verify",
    name = "Verify Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_certificate"},
    discovered = true,
    pos = {x = 4, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {cost = 8}},
    link_config = {j_certificate = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.cost/benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_click and #G.hand.highlighted == 1 then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            if (to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) >= to_big(card.ability.extra.cost/benefits) then
                local selected_seal = pseudorandom_element(G.P_CENTER_POOLS["Seal"], pseudoseed("pro_pnr"))
                G.hand.highlighted[1]:set_seal(selected_seal.key, nil, true)
                ease_dollars(-card.ability.extra.cost/benefits)
                card_eval_status_text(card, "dollars", -card.ability.extra.cost/benefits)
                G.E_MANAGER:add_event(Event({func = function()
                    G.hand:unhighlight_all()
                return true end}))
            end
        end
    end,
}

Partner_API.Partner{
    key = "jump",
    name = "Jump Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_throwback"},
    discovered = true,
    pos = {x = 0, y = 3},
    loc_txt = {},
    atlas = "Partner",
    individual_quips = true,
    config = {extra = {tag_mod = 1}},
    link_config = {j_throwback = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        local benefits = 1
        if link_level == 1 then
            key = key.."_"..link_level
            benefits = 2
        end
        return { key = key, vars = {card.ability.extra.tag_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.skip_blind then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            local tag_key = G.GAME.tags[#G.GAME.tags] and G.GAME.tags[#G.GAME.tags].key or "tag_double"
            if G.GAME.tags[#G.GAME.tags].ability and G.GAME.tags[#G.GAME.tags].ability.orbital_hand then
                G.orbital_hand = G.GAME.tags[#G.GAME.tags].ability.orbital_hand
            end
            for i = 1, benefits do add_tag(Tag(tag_key)) end
            play_sound("generic1", 0.9 + math.random()*0.1, 0.8)
            play_sound("holo1", 1.2 + math.random()*0.1, 0.4)
            G.orbital_hand = nil
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_duplicated_ex"), colour = G.C.GREEN})
        end
    end,
}

Partner_API.Partner{
    key = "vote",
    name = "Vote Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_hanging_chad"},
    discovered = true,
    pos = {x = 1, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {repetitions = 1}},
    link_config = {j_hanging_chad = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        local benefits = 1
        if link_level == 1 then
            key = key.."_"..link_level
            benefits = 2
        end
        return { key = key, vars = {card.ability.extra.repetitions*benefits} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra.repetitions*benefits,
                card = card
            }
        end
    end,
}

Partner_API.Partner{
    key = "bleed",
    name = "Bleed Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_bloodstone"},
    discovered = true,
    pos = {x = 2, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {xmult = 1.5}},
    link_config = {j_bloodstone = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {card.ability.extra.xmult*benefits} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local first_heart = nil
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_suit("Hearts") then
                    first_heart = context.scoring_hand[i]
                    break
                end
            end
            if context.other_card == first_heart then
                local link_level = self:get_link_level()
                local benefits = 1
                if link_level == 1 then benefits = 2 end
                return {
                    x_mult = card.ability.extra.xmult*benefits,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end,
}

Partner_API.Partner{
    key = "andrew",
    name = "Andrew Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_merry_andy"},
    discovered = true,
    pos = {x = 4, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {cost = 3, discard_mod = 1, draw_mod = 3}},
    link_config = {j_merry_andy = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {card.ability.extra.cost, card.ability.extra.discard_mod, card.ability.extra.draw_mod} }
    end,
    calculate = function(self, card, context)
        if context.partner_click and ((to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) >= to_big(card.ability.extra.cost)) then
            local link_level = self:get_link_level()
            if link_level ~= 1 and G.STATE == G.STATES.SELECTING_HAND then
                G.E_MANAGER:add_event(Event({func = function()
                    ease_discard(card.ability.extra.discard_mod)
                    ease_dollars(-card.ability.extra.cost)
                    card_eval_status_text(card, "dollars", -card.ability.extra.cost)
                return true end}))
            elseif link_level == 1 and G.hand and G.hand.cards[1] and G.deck and G.deck.cards[1] then
                local hand_space = math.min(#G.deck.cards, card.ability.extra.draw_mod)
                for i = 1, hand_space do
                    draw_card(G.deck, G.hand, i*100/hand_space, "up", true)
                end
                ease_dollars(-card.ability.extra.cost)
                card_eval_status_text(card, "dollars", -card.ability.extra.cost)
            end
        end
    end,
}

Partner_API.Partner{
    key = "thrill",
    name = "Thrill Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_stuntman"},
    discovered = true,
    pos = {x = 1, y = 4},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {chips = 50}},
    link_config = {j_stuntman = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 4 end
        return { vars = {card.ability.extra.chips*benefits} }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.chips >= 1 then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 4 end
            return {
                message = localize{type = "variable", key = "a_chips", vars = {card.ability.extra.chips*benefits}},
                chip_mod = card.ability.extra.chips*benefits,
                colour = G.C.CHIPS
            }
        end
    end,
}

Partner_API.Partner{
    key = "napkin",
    name = "Napkin Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_brainstorm"},
    discovered = true,
    pos = {x = 4, y = 4},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {joker_slot = 1}},
    link_config = {j_brainstorm = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {card.ability.extra.joker_slot} }
    end,
    calculate = function(self, card, context)
        local link_level = self:get_link_level()
        if link_level == 1 then
            local _card = G.jokers and G.jokers.cards[1]
            if _card and not context.no_blueprint then
                context.blueprint, context.blueprint_card = 0, card
                local _card_ret = _card:calculate_joker(context)
                context.blueprint, context.blueprint_card = nil, nil
                if _card_ret and _card_ret.duplication then
                    for k, v in ipairs(_card_ret) do
                        v.card = card
                        v.colour = G.C.RED
                    end
                    return _card_ret
                elseif _card_ret then
                    _card_ret.card = card
                    _card_ret.colour = G.C.RED
                    return _card_ret
                end
            end
        end
    end,
    calculate_begin = function(self, card)
        if G.jokers then G.jokers.config.card_limit = G.jokers.config.card_limit + 1 end
    end,
}

Partner_API.Partner{
    key = "valid",
    name = "Valid Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_drivers_license"},
    discovered = true,
    pos = {x = 3, y = 4},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {first_enhance = false}},
    link_config = {j_drivers_license = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local key = self.key
        if link_level == 1 then key = key.."_"..link_level end
        return { key = key, vars = {} }
    end,
    calculate = function(self, card, context)
        if context.before then
            local link_level = self:get_link_level()
            if not card.ability.extra.first_enhance or link_level == 1 then
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i].config.center == G.P_CENTERS.c_base and not context.scoring_hand[i].debuff then
                        card.ability.extra.first_enhance = true
                        context.scoring_hand[i]:set_ability(pseudorandom_element(G.P_CENTER_POOLS["Enhanced"], pseudoseed("per_pnr")), nil, true)
                        G.E_MANAGER:add_event(Event({func = function()
                            context.scoring_hand[i]:juice_up()
                        return true end}))
                        return {
                            message = localize("k_partner_enhanced"),
                            colour = G.C.SECONDARY_SET.Enhanced,
                            card = card
                        }
                    end
                end
            end
        end
        if context.setting_blind and card.ability.extra.first_enhance then
            card.ability.extra.first_enhance = false
        end
    end,
}

Partner_API.Partner{
    key = "blaze",
    name = "Blaze Partner",
    unlocked = false,
    unlock_condition = {type = "partner_joker_stake", stake = 8, joker = "j_burnt"},
    discovered = true,
    pos = {x = 3, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {odd = 4, upgrade_mod = 1}},
    link_config = {j_burnt = 1},
    loc_vars = function(self, info_queue, card)
        local link_level = self:get_link_level()
        local benefits = 1
        if link_level == 1 then benefits = 2 end
        return { vars = {""..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odd/benefits} }
    end,
    calculate = function(self, card, context)
        if context.pre_discard then
            local link_level = self:get_link_level()
            local benefits = 1
            if link_level == 1 then benefits = 2 end
            if pseudorandom("bla_pnr") < G.GAME.probabilities.normal/(card.ability.extra.odd/benefits) then
                local text, disp_text = G.FUNCS.get_poker_hand_info(context.full_hand)
                card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex")})
                update_hand_text({sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = localize(text, "poker_hands"), chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level = G.GAME.hands[text].level})
                level_up_hand(card, text, nil, card.ability.extra.upgrade_mod)
                update_hand_text({sound = "button", volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = "", level = ""})
            end
        end
    end,
}
