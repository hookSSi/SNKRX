BuyScreen = Object:extend()
BuyScreen:implement(State)
BuyScreen:implement(GameObject)
function BuyScreen:init(name)
  self:init_state(name)
  self:init_game_object()
end


function BuyScreen:on_exit()
  self.main:destroy()
  self.effects:destroy()
  self.ui:destroy()
  self.t:destroy()
  self.main = nil
  self.effects = nil
  self.ui = nil
  self.shop_text = nil
  self.party_text = nil
  self.sets_text = nil
  self.items_text = nil
  self.ng_text = nil
  self.level_text = nil
  self.characters = nil
  self.sets = nil
  self.cards = nil
  self.info_text = nil
  self.units = nil
  self.passives = nil
  self.player = nil
  self.t = nil
  self.springs = nil
  self.flashes = nil
  self.hfx = nil
  self.tutorial_button = nil
  self.restart_button = nil
  self.level_button = nil
end


function BuyScreen:on_enter(from, level, loop, units, passives, shop_level, shop_xp)
  self.level = level
  self.loop = loop
  self.units = units
  self.passives = passives
  self.shop_level = shop_level
  self.shop_xp = shop_xp
  camera.x, camera.y = gw/2, gh/2
  max_units = math.clamp(7 + current_new_game_plus + self.loop, 7, 12)

  input:set_mouse_visible(true)

  steam.friends.setRichPresence('steam_display', '#StatusFull')
  steam.friends.setRichPresence('text', 'Shop - Level ' .. self.level)

  self.main = Group()
  self.effects = Group()
  self.ui = Group()
  self.tutorial = Group()

  self.locked = locked_state and locked_state.locked
  LockButton{group = self.main, x = 205, y = 18, parent = self}

  self:set_cards(self.shop_level, nil, true)
  self:set_party_and_sets()
  self:set_items()

  self.shop_text = Text({{text = '[wavy_mid, fg]상점 [fg]- gold: [yellow]' .. gold, font = neodgm_font, alignment = 'center'}}, global_text_tags)
  self.party_text = Text({{text = '[wavy_mid, fg]파티 ' .. tostring(#units) .. '/' .. tostring(max_units), font = neodgm_font, alignment = 'center'}}, global_text_tags)
  self.sets_text = Text({{text = '[wavy_mid, fg]클래스', font = neodgm_font, alignment = 'center'}}, global_text_tags)
  self.items_text = Text({{text = '[wavy_mid, fg]아이템', font = neodgm_font, alignment = 'center'}}, global_text_tags)
  self.ng_text = Text({{text = '[fg]NG+' .. current_new_game_plus, font = neodgm_font, alignment = 'center'}}, global_text_tags)
  local get_elite_str = function(lvl)
    if (lvl-(25*self.loop)) % 6 == 0 or lvl % 25 == 0 then return ' (elite)'
    elseif (lvl-(25*self.loop)) % 3 == 0 then return ' (hard)'
    else return '' end
  end
  self.level_text = Text({{text = '[fg]Lv.' .. tostring(self.level) .. get_elite_str(self.level), font = neodgm_font, alignment = 'center'}}, global_text_tags)

  RerollButton{group = self.main, x = 150, y = 18, parent = self}
  GoButton{group = self.main, x = gw - 90, y = gh - 20, parent = self}
  LevelButton{group = self.main, x = gw/2, y = 18, parent = self}
  self.tutorial_button = Button{group = self.main, x = gw/2 + 129, y = 18, button_text = '?', fg_color = 'bg10', bg_color = 'bg', action = function()
    self.in_tutorial = true
    self.title_text = Text2{group = self.tutorial, x = gw/2, y = 23, lines = {{text = '[fg]WELCOME TO SNKRX!', font = pixelroborobo_font, alignment = 'center'}}}
    self.tutorial_text = Text2{group = self.tutorial, x = 240, y = 160, lines = {
      {text = '[fg]적을 자동 공격하는 여러 영웅들로 이루어진 뱀으로 플레이합니다.', font = neodgm_font, height_multiplier = 1.2},
      {text = '[fg][yellow]A/D[fg]나 [yellow]왼쪽/오른쪽 화살표[fg]를 눌러 뱀을 조종합니다.', font = neodgm_font, height_multiplier = 2.2},
      {text = '[fg]같은 영웅들을 조합하면 레밸업:', font = neodgm_font, height_multiplier = 1.2},
      {text = '[fg][yellow]Lv.3[fg]이 되면 영웅은 특별한 능력을 해금합니다.', font = neodgm_font, height_multiplier = 2.2},
      {text = '[fg]같은 클래스들을 모아 클래스 패시브 능력 해금:', font = neodgm_font, height_multiplier = 1.2},
      {text = '[fg]각 영웅은 [yellow]1 ~ 3[fg]개 클래스를 가집니다..', font = neodgm_font, height_multiplier = 2.2},
      {text = '[fg][yellow]5 gold마다 1 이자[fg]를 얻으며 최대 이자는 5입니다.', font = neodgm_font, height_multiplier = 1.2},
      {text = "[fg][yellow]25 gold[fg] 이상 모으면 추가적인 이자는 없다는 거죠", font = neodgm_font, height_multiplier = 2.2},
      {text = "[yellow, wavy_mid]행운을 빕니다!", font = neodgm_font, height_multiplier = 2.2, alignment = 'center'},
    }}

    self.tutorial_cards = {}
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 114, y = gh/2 - 30, character = 'swordsman', level = 1})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 134, y = gh/2 - 30, character = 'swordsman', level = 1})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 154, y = gh/2 - 30, character = 'swordsman', level = 1})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 114, y = gh/2 - 10, character = 'swordsman', level = 2})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 134, y = gh/2 - 10, character = 'swordsman', level = 2})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 154, y = gh/2 - 10, character = 'swordsman', level = 2})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 194, y = gh/2 - 30, character = 'swordsman', level = 2})
    table.insert(self.tutorial_cards, TutorialCharacterPart{group = self.tutorial, x = gw/2 + 194, y = gh/2 - 10, character = 'swordsman', level = 3})
    table.insert(self.tutorial_cards, TutorialClassIcon{group = self.tutorial, x = gw/2 + 114, y = gh/2 + 18, class = 'warrior', units = {}})
    table.insert(self.tutorial_cards, TutorialClassIcon{group = self.tutorial, x = gw/2 + 134, y = gh/2 + 18, class = 'warrior', units = {{character = 'swordsman'}, {character = 'barbarian'}, {character = 'juggernaut'}}})
    table.insert(self.tutorial_cards, TutorialClassIcon{group = self.tutorial, x = gw/2 + 154, y = gh/2 + 18, class = 'warrior', units = {{character = 'swordsman'}, {character = 'barbarian'}, {character = 'juggernaut'},
      {character = 'vagrant'}, {character = 'outlaw'}, {character = 'blade'}}
    })

    self.close_button = Button{group = self.tutorial, x = gw - 20, y = 20, button_text = 'x', bg_color = 'bg', fg_color = 'bg10', action = function()
      trigger:after(0.01, function()
        self:quit_tutorial()
      end)
    end}
  end, mouse_enter = function(b)
    b.info_text = InfoText{group = main.current.ui, force_update = true}
    b.info_text:activate({
      {text = '[fg]도움말', font = neodgm_font, alignment = 'center'},
    }, nil, nil, nil, nil, 16, 4, nil, 2)
    b.info_text.x, b.info_text.y = b.x, b.y + 20
  end, mouse_exit = function(b)
    if not b.info_text then return end
    b.info_text:deactivate()
    b.info_text.dead = true
    b.info_text = nil
  end}

  self.restart_button = Button{group = self.ui, x = gw/2 + 148, y = 18, force_update = true, button_text = 'R', fg_color = 'bg10', bg_color = 'bg', action = function(b)
    self.transitioning = true
    ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    locked_state = nil
    TransitionEffect{group = main.transitions, x = gw/2, y = gh/2, color = state.dark_transitions and bg[-2] or fg[0], transition_action = function()
      slow_amount = 1
      music_slow_amount = 1
      run_time = 0
      gold = 3
      passives = {}
      main_song_instance:stop()
      run_passive_pool = {
        'centipede', 'ouroboros_technique_r', 'ouroboros_technique_l', 'amplify', 'resonance', 'ballista', 'call_of_the_void', 'crucio', 'speed_3', 'damage_4', 'shoot_5', 'death_6', 'lasting_7',
        'defensive_stance', 'offensive_stance', 'kinetic_bomb', 'porcupine_technique', 'last_stand', 'seeping', 'deceleration', 'annihilation', 'malediction', 'hextouch', 'whispers_of_doom',
        'tremor', 'heavy_impact', 'fracture', 'meat_shield', 'hive', 'baneling_burst', 'blunt_arrow', 'explosive_arrow', 'divine_machine_arrow', 'chronomancy', 'awakening', 'divine_punishment',
        'assassination', 'flying_daggers', 'ultimatum', 'magnify', 'echo_barrage', 'unleash', 'reinforce', 'payback', 'enchanted', 'freezing_field', 'burning_field', 'gravity_field', 'magnetism',
        'insurance', 'dividends', 'berserking', 'unwavering_stance', 'unrelenting_stance', 'blessing', 'haste', 'divine_barrage', 'orbitism', 'psyker_orbs', 'psychosink', 'rearm', 'taunt', 'construct_instability',
        'intimidation', 'vulnerability', 'temporal_chains', 'ceremonial_dagger', 'homing_barrage', 'critical_strike', 'noxious_strike', 'infesting_strike', 'burning_strike', 'lucky_strike', 'healing_strike', 'stunning_strike',
        'silencing_strike', 'culling_strike', 'lightning_strike', 'psycholeak', 'divine_blessing', 'hardening', 'kinetic_strike',
      }
      max_units = math.clamp(7 + current_new_game_plus, 7, 12)
      main:add(BuyScreen'buy_screen')
      system.save_run()
      main:go_to('buy_screen', 1, 0, {}, passives, 1, 0)
    end, text = Text({{text = '[wavy, ' .. tostring(state.dark_transitions and 'fg' or 'bg') .. ']restarting...', font = neodgm_font, alignment = 'center'}}, global_text_tags)}
  end, mouse_enter = function(b)
    b.info_text = InfoText{group = main.current.ui, force_update = true}
    b.info_text:activate({
      {text = '[fg]재시작', font = neodgm_font, alignment = 'center'},
    }, nil, nil, nil, nil, 16, 4, nil, 2)
    b.info_text.x, b.info_text.y = b.x, b.y + 20
  end, mouse_exit = function(b)
    if not b.info_text then return end
    b.info_text:deactivate()
    b.info_text.dead = true
    b.info_text = nil
  end}

  trigger:tween(1, main_song_instance, {volume = 0.2, pitch = 1}, math.linear)

  locked_state = {locked = self.locked, cards = {self.cards[1] and self.cards[1].unit, self.cards[2] and self.cards[2].unit, self.cards[3] and self.cards[3].unit}} 
  system.save_run(self.level, self.loop, gold, self.units, self.passives, self.shop_level, self.shop_xp, run_passive_pool, locked_state)
end


function BuyScreen:update(dt)
  if main_song_instance:isStopped() then
    main_song_instance = _G[random:table{'song1', 'song2', 'song3', 'song4', 'song5'}]:play{volume = 0.2}
  end

  if not self.paused then
    run_time = run_time + dt
  end

  self:update_game_object(dt*slow_amount)

  if not self.in_tutorial and not self.paused then
    self.main:update(dt*slow_amount)
    self.effects:update(dt*slow_amount)
    self.ui:update(dt*slow_amount)
    if self.shop_text then self.shop_text:update(dt) end
    if self.sets_text then self.sets_text:update(dt) end
    if self.party_text then self.party_text:update(dt) end
    if self.items_text then self.items_text:update(dt) end
    if self.ng_text then self.ng_text:update(dt) end
    if self.level_text then self.level_text:update(dt) end
  else
    self.ui:update(dt*slow_amount)
    self.tutorial:update(dt*slow_amount)
  end

  if self.in_tutorial and input.escape.pressed then
    self:quit_tutorial()
  end

  if input.escape.pressed and not self.transitioning and not self.in_tutorial then
    if not self.paused then
      open_options(self)
    else
      close_options(self)
    end
  end

  for _, part in ipairs(self.characters) do
    part.y = 40 + (part.i-1)*19
  end
end


function BuyScreen:quit_tutorial()
  self.in_tutorial = false
  self.tutorial_text.dead = true
  self.tutorial_text = nil
  self.title_text.dead = true
  self.title_text = nil
  for _, t in ipairs(self.tutorial_cards) do t.dead = true end
  self.close_button.dead = true
  self.close_button = nil
  self.tutorial_cards = {}
  self.tutorial:update(0)
end


function BuyScreen:draw()
  self.main:draw()
  self.effects:draw()
  if self.items_text then self.items_text:draw(32, 145) end
  if self.level_text then self.level_text:draw(265, gh - 20) end

  if self.unit_grabbed then
    local x, y = camera:get_mouse_position()
    y = math.clamp(y, 40, 40 + (#self.units-1)*19)
    graphics.push(self.unit_grabbed.x, y, 0)
      graphics.rectangle(self.unit_grabbed.x, y, 14, 14, 3, 3, bg[5])
      graphics.print_centered(self.unit_grabbed.level, neodgm_font, self.unit_grabbed.x + 0.5, y + 2, 0, 1, 1, 0, 0, bg[10])
      for _, part in ipairs(self.unit_grabbed.parts) do
        part:draw(y)
      end
    graphics.pop()
  end

  if self.shop_text then self.shop_text:draw(64, 20) end
  if self.sets_text then self.sets_text:draw(328, 20) end
  if self.party_text then self.party_text:draw(440, 20) end
  if current_new_game_plus > 0 then self.ng_text:draw(265, gh - 40) end

  if self.paused then graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent) end
  self.ui:draw()

  if self.in_tutorial then
    graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent_2)
    arrow:draw(gw/2 + 173, gh/2 - 30, 0, 0.4, 0.35)
    arrow:draw(gw/2 + 173, gh/2 - 10, 0, 0.4, 0.35)
  end
  self.tutorial:draw()
end


function BuyScreen:buy(character, i)
  local bought
  if table.any(self.units, function(v) return v.character == character end) and gold >= character_tiers[character] then
    if table.any(self.units, function(v) return v.character == character and v.level == 3 end) then
      if not self.info_text then
        self.info_text = InfoText{group = main.current.ui}
        self.info_text:activate({
          {text = "[fg]this unit has already reached max level", font = neodgm_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text.x, self.info_text.y = gw - 140, gh - 20
      end
      self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')
    else
      gold = gold - character_tiers[character]
      self.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
      for _, unit in ipairs(self.units) do
        if unit.character == character then
          if unit.level == 1 then
            unit.reserve[1] = unit.reserve[1] + 1
            if unit.reserve[1] > 1 then
              unit.reserve[1] = 0
              unit.level = 2
              unit.spawn_effect = true
            end
          elseif unit.level == 2 then
            unit.reserve[1] = unit.reserve[1] + 1
            if unit.reserve[1] > 2 then
              if unit.reserve[2] == 1 then
                unit.reserve[2] = 0
                unit.reserve[1] = 0
                unit.level = 3
                unit.spawn_effect = true
              else
                unit.reserve[2] = unit.reserve[2] + 1
                unit.reserve[1] = 0
              end
            end
          end
        end
      end
      bought = true
    end
  else
    if #self.units >= max_units then
      if not self.info_text then
        self.info_text = InfoText{group = main.current.ui}
        self.info_text:activate({
          {text = '[fg]maximum number of units [yellow](' .. max_units .. ') [fg]reached', font = neodgm_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text.x, self.info_text.y = gw - 140, gh - 20
      end
      self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')
    else
      if gold >= character_tiers[character] then
        gold = gold - character_tiers[character]
        self.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
        table.insert(self.units, {character = character, level = 1, reserve = {0, 0}})
        bought = true
      end
    end
  end
  self:set_party_and_sets()
  return bought
end


function BuyScreen:gain_gold(amount)
  gold = gold + amount or 0
  self.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
end


function BuyScreen:set_cards(shop_level, dont_spawn_effect, first_call)
  if self.cards then for i = 1, 3 do if self.cards[i] then self.cards[i]:die(dont_spawn_effect) end end end
  self.cards = {}
  local all_units = {}
  local unit_1
  local unit_2
  local unit_3
  local shop_level = shop_level or 1
  local tier_weights = level_to_shop_odds[shop_level]
  repeat 
    unit_1 = random:table(tier_to_characters[random:weighted_pick(unpack(tier_weights))])
    unit_2 = random:table(tier_to_characters[random:weighted_pick(unpack(tier_weights))])
    unit_3 = random:table(tier_to_characters[random:weighted_pick(unpack(tier_weights))])
    all_units = {unit_1, unit_2, unit_3}
  until not table.all(all_units, function(v) return table.any(non_attacking_characters, function(u) return v == u end) end)
  if first_call and locked_state then
    if locked_state.cards[1] then self.cards[1] = ShopCard{group = self.main, x = 60, y = 75, w = 80, h = 90, unit = locked_state.cards[1], parent = self, i = 1} end
    if locked_state.cards[2] then self.cards[2] = ShopCard{group = self.main, x = 140, y = 75, w = 80, h = 90, unit = locked_state.cards[2], parent = self, i = 2} end
    if locked_state.cards[3] then self.cards[3] = ShopCard{group = self.main, x = 220, y = 75, w = 80, h = 90, unit = locked_state.cards[3], parent = self, i = 3} end
  else
    self.cards[1] = ShopCard{group = self.main, x = 60, y = 75, w = 80, h = 90, unit = unit_1, parent = self, i = 1}
    self.cards[2] = ShopCard{group = self.main, x = 140, y = 75, w = 80, h = 90, unit = unit_2, parent = self, i = 2}
    self.cards[3] = ShopCard{group = self.main, x = 220, y = 75, w = 80, h = 90, unit = unit_3, parent = self, i = 3}
  end
end


function BuyScreen:set_party_and_sets()
  if self.characters then for _, part in ipairs(self.characters) do part:die() end end
  self.characters = {}
  local y = 40
  for i, unit in ipairs(self.units) do
    table.insert(self.characters, CharacterPart{group = self.main, x = gw - 30, y = y + (i-1)*19, character = unit.character, level = unit.level, reserve = unit.reserve, i = i, spawn_effect = unit.spawn_effect, parent = self})
    unit.spawn_effect = false
  end

  if self.sets then for _, icon in ipairs(self.sets) do icon:die(true) end end
  self.sets = {}
  local classes = get_classes(self.units)
  for i, class in ipairs(classes) do
    local x, y
    if #classes <= 6 then x, y = math.index_to_coordinates(i, 2)
    else x, y = math.index_to_coordinates(i, 3) end
    table.insert(self.sets, ClassIcon{group = self.main, x = (#classes <= 6 and 319 or 308) + (x-1)*20, y = 45 + (y-1)*56, class = class, units = self.units, parent = self})
  end
end


function BuyScreen:set_items()
  if self.items then for _, item in ipairs(self.items) do item:die() end end
  self.items = {}
  local y = 182
  for k, passive in ipairs(self.passives) do
    local i, j = math.index_to_coordinates(k, 4)
    table.insert(self.items, ItemCard{group = self.main, x = 45 + (i-1)*60, y = y + (j-1)*50, w = 40, h = 50, passive = passive.passive , level = passive.level, xp = passive.xp, parent = self, i = k})
  end
end


TutorialCharacterPart = Object:extend()
TutorialCharacterPart:implement(GameObject)
function TutorialCharacterPart:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.sx*20, self.sy*20)
  self.interact_with_mouse = true
  self.spring:pull(0.2, 200, 10)
end


function TutorialCharacterPart:update(dt)
  self:update_game_object(dt)
end


function TutorialCharacterPart:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    graphics.rectangle(self.x, self.y, 14, 14, 3, 3, self.highlighted and fg[0] or character_colors[self.character])
    graphics.print_centered(self.level, neodgm_font, self.x + 0.5, self.y + 2, 0, 1, 1, 0, 0, self.highlighted and fg[-5] or _G[character_color_strings[self.character]][-5])
  graphics.pop()
end


function TutorialCharacterPart:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.tutorial}
  self.info_text:activate({
    {text = '[' .. character_color_strings[self.character] .. ']' .. self.character:capitalize() .. '[fg] - [yellow]Lv.' .. self.level,
    font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = '[fg]Classes: ' .. character_class_strings[self.character], font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = character_descriptions[self.character](self.level), font = neodgm_font, alignment = 'center', height_multiplier = 2},
    {text = '[' .. (self.level == 3 and 'yellow' or 'light_bg') .. ']Lv.3 [' .. (self.level == 3 and 'fg' or 'light_bg') .. ']Effect - ' .. 
      (self.level == 3 and character_effect_names[self.character] or character_effect_names_gray[self.character]), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = (self.level == 3 and character_effect_descriptions[self.character]() or character_effect_descriptions_gray[self.character]()), font = neodgm_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + gh/4 - 12
end


function TutorialCharacterPart:on_mouse_exit()
  self.selected = false
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil
end



CharacterPart = Object:extend()
CharacterPart:implement(GameObject)
function CharacterPart:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.sx*20, self.sy*20)
  self.interact_with_mouse = true
  self.parts = {}
  local x = self.x - 20
  if self.reserve then
    if self.reserve[2] and self.reserve[2] == 1 then
      table.insert(self.parts, CharacterPart{group = main.current.main, x = x, y = self.y, character = self.character, level = 2, i = self.i, parent = self})
      x = x - 20
    end
    for i = 1, self.reserve and self.reserve[1] or 0 do
      table.insert(self.parts, CharacterPart{group = main.current.main, x = x, y = self.y, character = self.character, level = 1, sx = 0.9, sy = 0.9, i = self.i, parent = self})
      x = x - 20
    end
  end
  self.spring:pull(0.2, 200, 10)
  if self.spawn_effect then SpawnEffect{group = main.current.effects, x = self.x, y = self.y, color = character_colors[self.character]} end
  self.just_created = true
  self.t:after(0.1, function() self.just_created = false end)
end


function CharacterPart:update(dt)
  self:update_game_object(dt)

  if self.cant_click then return end

  if not self.parent:is(CharacterPart) then
    if input.m1.pressed and self.colliding_with_mouse then
      self.grabbed = true
      self.parent.unit_grabbed = self
    end

    if self.grabbed and input.m1.released then
      self.grabbed = false
      self.parent.unit_grabbed = false
      self.spring:pull(0.2, 200, 10)
      --[[
      for i, unit in ipairs(self.parent.units) do
        print(unit.character)
      end
      for i, character in ipairs(self.parent.characters) do
        print(character.y, character.character, character.shape.y)
      end
      ]]--
    end

    for _, part in ipairs(self.parts) do
      part.grabbed = self.grabbed
    end

    if self.parent.unit_grabbed and self.parent.unit_grabbed == self then
      local x, y = camera:get_mouse_position()
      local i
      if y >= self.y - 19 and y <= self.y + 19 then i = self.i
      elseif y < self.y - 19 then i = self.i - 1
      elseif y > self.y + 19 then i = self.i + 1
      end
      i = math.clamp(i, 1, #self.parent.units)
      -- i = math.clamp(math.floor((y - 40)/19) + 1, 1, #self.parent.units)
      self.parent.units[self.i], self.parent.units[i] = self.parent.units[i], self.parent.units[self.i]
      self.parent.characters[self.i], self.parent.characters[i] = self.parent.characters[i], self.parent.characters[self.i]
      self.parent.characters[self.i].i, self.parent.characters[i].i = self.i, i
    end
  end

  if self.selected and input.m2.pressed and not self.just_created then
    _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    if self.reserve then
      self.parent:gain_gold(self:get_sale_price())
      table.remove(self.parent.units, self.i)
      self:die()
      self.parent:set_party_and_sets()
      self.parent:refresh_cards()
      self.parent.party_text:set_text({{text = '[wavy_mid, fg]party ' .. tostring(#self.parent.units) .. '/' .. tostring(max_units), font = neodgm_font, alignment = 'center'}})
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    else
      self.parent.parent:gain_gold(self:get_sale_price())
      self.parent.parent.units[self.i].reserve[self.level] = self.parent.parent.units[self.i].reserve[self.level] - 1
      self:die()
      self.parent.parent:set_party_and_sets()
      self.parent.parent:refresh_cards()
      system.save_run(self.parent.parent.level, self.parent.parent.loop, gold, self.parent.parent.units, self.parent.parent.passives, self.parent.parent.shop_level, self.parent.parent.shop_xp, run_passive_pool, locked_state)
    end
  end

  self.shape:move_to(self.x, self.y)
  for _, part in ipairs(self.parts) do
    part.y = self.y
  end
end


function CharacterPart:draw(y)
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    if self.grabbed then
      --[[
      graphics.rectangle(self.x, self.y, 14, 14, 3, 3, bg[5])
      graphics.print_centered(self.level, pixul_font, self.x + 0.5, self.y + 2, 0, 1, 1, 0, 0, bg[10])
      ]]--
    else
      graphics.rectangle(self.x, self.y, 14, 14, 3, 3, self.highlighted and bg[10] or character_colors[self.character])
      graphics.print_centered(self.level, neodgm_font, self.x + 0.5, self.y + 2, 0, 1, 1, 0, 0, self.highlighted and bg[5] or _G[character_color_strings[self.character]][-5])
    end
    if y then
      graphics.rectangle(self.x, y, 14, 14, 3, 3, bg[5])
      graphics.print_centered(self.level, neodgm_font, self.x + 0.5, y + 2, 0, 1, 1, 0, 0, bg[10])
    end
  graphics.pop()
end


function CharacterPart:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui, force_update = self.force_update}
  self.info_text:activate({
    {text = '[' .. character_color_strings[self.character] .. ']' .. self.character:capitalize() .. '[fg] - [yellow]Lv.' .. self.level .. '[fg], tier [yellow]' .. character_tiers[self.character] .. '[fg] - sells for [yellow]' ..
      self:get_sale_price(), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = '[fg]Classes: ' .. character_class_strings[self.character], font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = character_descriptions[self.character](self.level), font = neodgm_font, alignment = 'center', height_multiplier = 2},
    {text = '[' .. (self.level == 3 and 'yellow' or 'light_bg') .. ']Lv.3 [' .. (self.level == 3 and 'fg' or 'light_bg') .. ']Effect - ' .. 
      (self.level == 3 and character_effect_names[self.character] or character_effect_names_gray[self.character]), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = (self.level == 3 and character_effect_descriptions[self.character]() or character_effect_descriptions_gray[self.character]()), font = neodgm_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10

  --[[
  if self.parent:is(BuyScreen) then
    for _, set in ipairs(self.parent.sets) do
      if table.any(character_classes[self.character], function(v) return v == set.class end) then
        set:highlight()
      end
    end
  end
  ]]--
end


function CharacterPart:get_sale_price()
  if not character_tiers[self.character] then return 0 end
  local total = 0
  total = total + ((self.level == 1 and character_tiers[self.character]) or (self.level == 2 and 2*character_tiers[self.character]) or (self.level == 3 and 6*character_tiers[self.character]) or 0)
  if self.reserve then
    if self.reserve[2] then total = total + self.reserve[2]*character_tiers[self.character]*2 end
    if self.reserve[1] then total = total + self.reserve[1]*character_tiers[self.character] end
  end
  return total
end


function CharacterPart:on_mouse_exit()
  self.selected = false
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil

  --[[
  if self.parent:is(BuyScreen) then
    for _, set in ipairs(self.parent.sets) do
      if table.any(character_classes[self.character], function(v) return v == set.class end) then
        set:unhighlight()
      end
    end
  end
  ]]--
end


function CharacterPart:die()
  self.dead = true
  for _, part in ipairs(self.parts) do part:die() end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end

  --[[
  if self.selected and self.parent:is(BuyScreen) then
    for _, set in ipairs(self.parent.sets) do
      if table.any(character_classes[self.character], function(v) return v == set.class end) then
        set:unhighlight()
      end
    end
  end
  ]]--
end


function CharacterPart:highlight()
  self.highlighted = true
  self.spring:pull(0.2, 200, 10)
end


function CharacterPart:unhighlight()
  self.highlighted = false
  self.spring:pull(0.05, 200, 10)
end




PassiveCard = Object:extend()
PassiveCard:implement(GameObject)
function PassiveCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
  self.passive_name =  Text({{text = '[fg, wavy_mid]' .. passive_names[self.passive], font = neodgm_font, alignment = 'center'}}, global_text_tags)
  self.passive_description = passive_descriptions[self.passive]
  self.spring:pull(0.2, 200, 10)
end


function PassiveCard:update(dt)
  self:update_game_object(dt)
  self.passive_name:update(dt)

  if ((self.selected and input.m1.pressed) or input[tostring(self.card_i)].pressed) and self.arena.choosing_passives then
    self.arena.choosing_passives = false
    table.insert(self.arena.passives, {passive = self.passive, level = 1, xp = 0})
    self.arena:restore_passives_to_pool(self.card_i)
    trigger:tween(0.25, _G, {slow_amount = 1, music_slow_amount = 1}, math.linear, function()
      slow_amount = 1
      music_slow_amount = 1
      self.arena:transition()
    end)
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self:die()
  end
end


function PassiveCard:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    self.passive_name:draw(self.x, self.y - 20)
    _G[self.passive]:draw(self.x, self.y + 24, 0, 1, 1, 0, 0, fg[0])
  graphics.pop()
end


function PassiveCard:on_mouse_enter()
  self.selected = true
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui, force_update = true}
  self.info_text:activate({
    {text = self.passive_description, font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + gh/4 - 6
end


function PassiveCard:on_mouse_exit()
  self.selected = false
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function PassiveCard:die()
  self.dead = true
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end




ItemCard = Object:extend()
ItemCard:implement(GameObject)
function ItemCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
  self.max_xp = (self.level == 0 and 0) or (self.level == 1 and 2) or (self.level == 2 and 3) or (self.level == 3 and 0)
  self.unlevellable = table.any(unlevellable_items, function(v) return v == self.passive end)
end


function ItemCard:update(dt)
  self:update_game_object(dt)

  if self.parent:is(Arena) then return end

  if self.selected and input.m1.pressed and not self.unlevellable then
    if self.level >= 3 then return end
    if gold < 5 then
      self.spring:pull(0.2, 200, 10)
      self.selected = true
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      if not self.info_text_2 then
        self.info_text_2 = InfoText{group = main.current.ui}
        self.info_text_2:activate({
          {text = '[fg]not enough gold', font = neodgm_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text_2.x, self.info_text_2.y = gw/2, gh/2 + 30
      end
      self.t:after(2, function() self.info_text_2:deactivate(); self.info_text_2.dead = true; self.info_text_2 = nil end, 'info_text_2')
    else
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.xp = self.xp + 1
      if self.xp >= self.max_xp then
        self.xp = 0
        self.level = self.level + 1
        self.max_xp = (self.level == 0 and 0) or (self.level == 1 and 2) or (self.level == 2 and 3) or (self.level == 3 and 0)
        if self.level == 2 then spawn_mark1:play{pitch = 1, volume = 0.6} end
        if self.level == 3 then
          spawn_mark1:play{pitch = 1.2, volume = 0.6}
          level_up1:play{pitch = 1, volume = 0.5}
        end
      end
      self:create_info_text()
      self.selected = true
      self.spring:pull(0.2, 200, 10)
      gold = gold - 5
      for _, passive in ipairs(self.parent.passives) do
        if passive.passive == self.passive then
          passive.level = self.level
          passive.xp = self.xp
        end
      end
      self.parent.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
      self.text = Text({{text = '[bg10]' .. tostring(self.parent.shop_level), font = neodgm_font, alignment = 'center'}}, global_text_tags)
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    end
  end

  if self.selected and input.m2.pressed then
    _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self.parent:gain_gold((self.level == 1 and 10) or (self.level == 2 and 20) or (self.level == 3 and 30))
    table.insert(run_passive_pool, self.passive)
    table.remove(self.parent.passives, self.i)
    input.m2.pressed = false
    self.parent:set_items()
    system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
  end
end


function ItemCard:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    if self.selected then
      graphics.rectangle(self.x, self.y, self.w, self.h, 6, 6, bg[-1])
    end
    _G[self.passive]:draw(self.x, self.y, 0, 0.8, 0.7, 0, 0, fg[0])
    if not self.unlevellable and not self.parent:is(Arena) then
      local x, y = self.x + self.w/2.5, self.y - self.h/2.5
      if self.level == 1 then
        graphics.rectangle(x - 2, y, 2, 2, nil, nil, self.xp >= 1 and fg[0] or bg[5])
        graphics.rectangle(x + 2, y, 2, 2, nil, nil, bg[5])
      elseif self.level == 2 then
        graphics.rectangle(x - 4, y, 2, 2, nil, nil, self.xp >= 1 and fg[0] or bg[5])
        graphics.rectangle(x, y, 2, 2, nil, nil, self.xp >= 2 and fg[0] or bg[5])
        graphics.rectangle(x + 4, y, 2, 2, nil, nil, bg[5])
      end
    end
  graphics.pop()
end


function ItemCard:create_info_text()
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil
  if self.level == 3 or self.unlevellable then
    self.info_text = InfoText{group = main.current.ui, force_update = true}
    self.info_text:activate({
      {text = '[fg]' .. passive_names[self.passive] .. ', [yellow]Lv.' .. self.level, font = neodgm_font, alignment = 'center',
        height_multiplier = 1.25},
      {text = passive_descriptions_level[self.passive](self.level), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    }, nil, nil, nil, nil, 16, 4, nil, 2)
    self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
  else
    self.info_text = InfoText{group = main.current.ui, force_update = true}
    self.info_text:activate({
      {text = '[fg]' .. passive_names[self.passive] .. ', [yellow]Lv.' .. self.level .. '[fg], XP: [yellow]' .. self.xp .. '/' .. self.max_xp .. '[fg], +1 XP cost: [yellow]5[fg], sells for: [yellow]' .. 
        tostring((self.level == 1 and 10) or (self.level == 2 and 20) or (self.level == 3 and 30)), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
      {text = passive_descriptions_level[self.passive](self.level), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    }, nil, nil, nil, nil, 16, 4, nil, 2)
    self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
  end
end


function ItemCard:on_mouse_enter()
  self.selected = true
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  self:create_info_text()
end


function ItemCard:on_mouse_exit()
  self.selected = false
  self.info_text:deactivate()
  self.info_text.dead = true
  self.info_text = nil
end


function ItemCard:die()
  self.dead = true
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end


function BuyScreen:refresh_cards()
  for i = 1, 3 do
    if self.cards[i] then
      self.cards[i]:refresh()
    end
  end
end



ShopCard = Object:extend()
ShopCard:implement(GameObject)
function ShopCard:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, self.w, self.h)
  self.interact_with_mouse = true
  self.character_icon = CharacterIcon{group = main.current.effects, x = self.x, y = self.y - 26, character = self.unit, parent = self}
  self.class_icons = {}
  for i, class in ipairs(character_classes[self.unit]) do
    local x = self.x
    if #character_classes[self.unit] == 2 then x = self.x - 10
    elseif #character_classes[self.unit] == 3 then x = self.x - 20 end
    table.insert(self.class_icons, ClassIcon{group = main.current.effects, x = x + (i-1)*20, y = self.y + 6, class = class, character = self.unit, units = self.parent.units, parent = self})
  end
  self.cost = character_tiers[self.unit]
  self.spring:pull(0.2, 200, 10)
  self:refresh()
end


function ShopCard:refresh()
  self.owned = table.any(self.parent.units, function(v) return v.character == self.unit end)
  if self.owned then
    self.owned_n = 0
    for _, unit in ipairs(self.parent.units) do
      if unit.character == self.unit then
        self.owned_n = self.owned_n + ((unit.level == 1 and 1) or (unit.level == 2 and 3) or (unit.level == 3 and 9))
        if unit.reserve then
          self.owned_n = self.owned_n + (unit.reserve[2] or 0)*3
          self.owned_n = self.owned_n + (unit.reserve[1] or 0)
        end
      end
    end
  end
end


function ShopCard:update(dt)
  self:update_game_object(dt)

  if (self.selected and input.m1.pressed) or input[tostring(self.i)].pressed then
    if self.parent:buy(self.unit, self.i) then
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      _G[random:table{'coins1', 'coins2', 'coins3'}]:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self:die()
      self.parent.cards[self.i] = nil
      self.parent:refresh_cards()
      self.parent.party_text:set_text({{text = '[wavy_mid, fg]party ' .. tostring(#self.parent.units) .. '/' .. tostring(max_units), font = neodgm_font, alignment = 'center'}})
      locked_state = {locked = self.parent.locked, cards = {self.parent.cards[1] and self.parent.cards[1].unit, self.parent.cards[2] and self.parent.cards[2].unit, self.parent.cards[3] and self.parent.cards[3].unit}} 
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    else
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.spring:pull(0.2, 200, 10)
      self.character_icon.spring:pull(0.2, 200, 10)
      for _, ci in ipairs(self.class_icons) do ci.spring:pull(0.2, 200, 10) end
    end
  end
end


function ShopCard:select()
  self.selected = true
  self.spring:pull(0.2, 200, 10)
  self.t:every_immediate(1.4, function()
    if self.selected then
      self.t:tween(0.7, self, {sx = 0.97, sy = 0.97, plus_r = -math.pi/32}, math.linear, function()
        self.t:tween(0.7, self, {sx = 1.03, sy = 1.03, plus_r = math.pi/32}, math.linear, nil, 'pulse_1')
      end, 'pulse_2')
    end
  end, nil, nil, 'pulse')
end


function ShopCard:unselect()
  self.selected = false
  self.t:cancel'pulse'
  self.t:cancel'pulse_1'
  self.t:cancel'pulse_2'
  self.t:tween(0.1, self, {sx = 1, sy = 1, plus_r = 0}, math.linear, function() self.sx, self.sy, self.plus_r = 1, 1, 0 end, 'pulse')
end


function ShopCard:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    if self.selected then
      graphics.rectangle(self.x, self.y, self.w, self.h, 6, 6, bg[-1])
    end
    if self.owned then
      local x, y = self.x + self.w/5, self.y - self.h/2 + 12
      if self.owned_n == 1 then
        graphics.rectangle(x, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 2 then
        graphics.rectangle(x, y, 2, 2, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 4, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 3 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 4 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 5, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 5 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 5, y, 2, 2, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 9, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 6 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 6, y, 4, 4, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 7 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 6, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 11, y, 2, 2, nil, nil, character_colors[self.unit])
      elseif self.owned_n == 8 then
        graphics.rectangle(x, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 6, y, 4, 4, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 11, y, 2, 2, nil, nil, character_colors[self.unit])
        graphics.rectangle(x + 15, y, 2, 2, nil, nil, character_colors[self.unit])
      end
    end
  graphics.pop()
end


function ShopCard:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.spring:pull(0.1)
  self.character_icon.spring:pull(0.1, 200, 10)
  for _, class_icon in ipairs(self.class_icons) do
    class_icon.selected = true
    class_icon.spring:pull(0.1, 200, 10)
  end
end


function ShopCard:on_mouse_exit()
  self.selected = false
  for _, class_icon in ipairs(self.class_icons) do class_icon.selected = false end
end


function ShopCard:die(dont_spawn_effect)
  self.dead = true
  self.character_icon:die(dont_spawn_effect)
  for _, class_icon in ipairs(self.class_icons) do class_icon:die(dont_spawn_effect) end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end




CharacterIcon = Object:extend()
CharacterIcon:implement(GameObject)
function CharacterIcon:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 40, 20)
  self.interact_with_mouse = true
  self.character_text = Text({{text = '[' .. character_color_strings[self.character] .. ']' .. string.lower(character_names[self.character]), font = neodgm_font, alignment = 'center'}}, global_text_tags)
end


function CharacterIcon:update(dt)
  self:update_game_object(dt)
  self.character_text:update(dt)
end


function CharacterIcon:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    graphics.rectangle(self.x, self.y - 7, 14, 14, 3, 3, character_colors[self.character])
    graphics.print_centered(self.parent.cost, neodgm_font, self.x + 0.5, self.y - 5, 0, 1, 1, 0, 0, _G[character_color_strings[self.character]][-5])
    self.character_text:draw(self.x, self.y + 10)
  graphics.pop()
end


function CharacterIcon:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  self.info_text = InfoText{group = main.current.ui}
  self.info_text:activate({
    {text = '[' .. character_color_strings[self.character] .. ']' .. self.character:capitalize() .. '[fg] - cost: [yellow]' .. self.parent.cost, font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = '[fg]Classes: ' .. character_class_strings[self.character], font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = character_descriptions[self.character](1), font = neodgm_font, alignment = 'center', height_multiplier = 2},
    {text = '[' .. (self.level == 3 and 'yellow' or 'light_bg') .. ']Lv.3 [' .. (self.level == 3 and 'fg' or 'light_bg') .. ']Effect - ' .. 
      (self.level == 3 and character_effect_names[self.character] or character_effect_names_gray[self.character]), font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = (self.level == 3 and character_effect_descriptions[self.character]() or character_effect_descriptions_gray[self.character]()), font = neodgm_font, alignment = 'center'},
    -- {text = character_stats[self.character](1), font = pixul_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
end


function CharacterIcon:on_mouse_exit()
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil
end


function CharacterIcon:die(dont_spawn_effect)
  self.dead = true
  if not dont_spawn_effect then SpawnEffect{group = main.current.effects, x = self.x, y = self.y + 4, color = character_colors[self.character]} end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end
end



TutorialClassIcon = Object:extend()
TutorialClassIcon:implement(GameObject)
function TutorialClassIcon:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y + 11, 20, 40)
  self.interact_with_mouse = true
  self.spring:pull(0.2, 200, 10)
end


function TutorialClassIcon:update(dt)
  self:update_game_object(dt)
end


function TutorialClassIcon:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    local i, j, k, n = class_set_numbers[self.class](self.units)

    graphics.rectangle(self.x, self.y, 16, 24, 4, 4, self.highlighted and fg[0] or ((n >= i) and class_colors[self.class] or bg[3]))
    _G[self.class]:draw(self.x, self.y, 0, 0.3, 0.3, 0, 0, self.highlighted and fg[-5] or ((n >= i) and _G[class_color_strings[self.class]][-5] or bg[10]))
    graphics.rectangle(self.x, self.y + 26, 16, 16, 3, 3, self.highlighted and fg[0] or bg[3])
    if i == 2 and not k then
      if self.highlighted then
        graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and class_colors[self.class] or bg[10], 3)
      end
    elseif i == 3 then
      if self.highlighted then
        graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and class_colors[self.class] or bg[10], 3)
      end
    end
  graphics.pop()
end


function TutorialClassIcon:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  local i, j, k, owned = class_set_numbers[self.class](self.units)
  self.info_text = InfoText{group = main.current.tutorial}
  self.info_text:activate({
    {text = '[' .. class_color_strings[self.class] .. ']' .. self.class:capitalize() .. '[fg] - owned: [yellow]' .. owned, font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = class_descriptions[self.class]((owned >= j and 2) or (owned >= i and 1) or 0), font = neodgm_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2 - 25, gh/2 + 25
end


function TutorialClassIcon:on_mouse_exit()
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil
end




ClassIcon = Object:extend()
ClassIcon:implement(GameObject)
function ClassIcon:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y + 11, 20, 40)
  self.interact_with_mouse = true
  self.t:every(0.5, function() self.flash = not self.flash end)
  self.spring:pull(0.2, 200, 10)
end


function ClassIcon:update(dt)
  self:update_game_object(dt)
end


function ClassIcon:draw()
  graphics.push(self.x, self.y, 0, self.sx*self.spring.x, self.sy*self.spring.x)
    local i, j, k, n = class_set_numbers[self.class](self.units)
    local next_n
    if self.parent:is(ShopCard) then
      next_n = n+1
      if k then
        if next_n > k then next_n = nil end
      else
        if next_n > j then next_n = nil end
      end
      if table.any(self.units, function(v) return v.character == self.character end) then next_n = nil end
    end

    graphics.rectangle(self.x, self.y, 16, 24, 4, 4, self.highlighted and fg[0] or ((n >= i) and class_colors[self.class] or bg[3]))
    _G[self.class]:draw(self.x, self.y, 0, 0.3, 0.3, 0, 0, self.highlighted and fg[-5] or ((n >= i) and _G[class_color_strings[self.class]][-5] or bg[10]))
    graphics.rectangle(self.x, self.y + 26, 16, 16, 3, 3, self.highlighted and fg[0] or bg[3])
    if i == 1 then
      if self.highlighted then
        graphics.rectangle(self.x, self.y + 26, 3, 9, nil, nil, (n >= 1) and fg[-5] or fg[-10])
      else
        graphics.rectangle(self.x, self.y + 26, 3, 9, nil, nil, (n >= 1) and class_colors[self.class] or bg[10])
      end
      if next_n then
        if next_n == 1 then
          graphics.rectangle(self.x, self.y + 26, 3, 9, nil, nil, self.flash and class_colors[self.class] or bg[10])
        end
      end

    elseif i == 2 and not k then
      if self.highlighted then
        graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, (n >= 4) and class_colors[self.class] or bg[10], 3)
      end
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 3, self.y + 20, self.x - 3, self.y + 25, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 3, self.y + 27, self.x - 3, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x + 4, self.y + 20, self.x + 4, self.y + 25, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 4, self.y + 27, self.x + 4, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end
    elseif i == 2 and k == 6 then
      if self.highlighted then
        graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, (n >= 4) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, (n >= 5) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, (n >= 6) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, (n >= 4) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, (n >= 5) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, (n >= 6) and class_colors[self.class] or bg[10], 3)
      end
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 5, self.y + 21, self.x - 5, self.y + 24, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 5, self.y + 28, self.x - 5, self.y + 31, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x + 0, self.y + 21, self.x + 0, self.y + 24, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 0, self.y + 28, self.x + 0, self.y + 31, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 5 then
          graphics.line(self.x + 5, self.y + 21, self.x + 5, self.y + 24, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 6 then
          graphics.line(self.x + 5, self.y + 28, self.x + 5, self.y + 31, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end

    elseif i == 3 then
      if self.highlighted then
        graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and fg[-5] or fg[-10], 3)
        graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and fg[-5] or fg[-10], 3)
        graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and fg[-5] or fg[-10], 3)
      else
        graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, (n >= 1) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, (n >= 2) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, (n >= 3) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, (n >= 4) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, (n >= 5) and class_colors[self.class] or bg[10], 3)
        graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, (n >= 6) and class_colors[self.class] or bg[10], 3)
      end
      if next_n then
        if next_n == 1 then
          graphics.line(self.x - 3, self.y + 19, self.x - 3, self.y + 22, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 2 then
          graphics.line(self.x - 3, self.y + 24, self.x - 3, self.y + 27, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 3 then
          graphics.line(self.x - 3, self.y + 29, self.x - 3, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 4 then
          graphics.line(self.x + 4, self.y + 19, self.x + 4, self.y + 22, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 5 then
          graphics.line(self.x + 4, self.y + 24, self.x + 4, self.y + 27, self.flash and class_colors[self.class] or bg[10], 3)
        elseif next_n == 6 then
          graphics.line(self.x + 4, self.y + 29, self.x + 4, self.y + 32, self.flash and class_colors[self.class] or bg[10], 3)
        end
      end
    end
  graphics.pop()
end


function ClassIcon:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  self.spring:pull(0.2, 200, 10)
  local i, j, k, owned = class_set_numbers[self.class](self.units)
  self.info_text = InfoText{group = main.current.ui}
  self.info_text:activate({
    {text = '[' .. class_color_strings[self.class] .. ']' .. (self.class == 'conjurer' and 'Builder' or self.class:capitalize()) .. '[fg] - owned: [yellow]' .. owned, font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
    {text = class_descriptions[self.class]((k and (owned >= k and 3)) or (owned >= j and 2) or (owned >= i and 1) or 0), font = neodgm_font, alignment = 'center'},
  }, nil, nil, nil, nil, 16, 4, nil, 2)
  self.info_text.x, self.info_text.y = gw/2, gh/2 + 10

  if not self.parent:is(ShopCard) then
    for _, character in ipairs(self.parent.characters) do
      if table.any(character_classes[character.character], function(v) return v == self.class end) then
        character:highlight()
        for _, c in ipairs(character.parts) do
          c:highlight()
        end
      end
    end
  end
end


function ClassIcon:on_mouse_exit()
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil

  if not self.parent:is(ShopCard) then
    for _, character in ipairs(self.parent.characters) do
      if table.any(character_classes[character.character], function(v) return v == self.class end) then
        character:unhighlight()
        for _, c in ipairs(character.parts) do
          c:unhighlight()
        end
      end
    end
  end
end


function ClassIcon:die(dont_spawn_effect)
  self.dead = true
  local i, j, k, n = class_set_numbers[self.class](self.units)
  if not dont_spawn_effect then SpawnEffect{group = main.current.effects, x = self.x, y = self.y + 4, color = (n >= i) and class_colors[self.class] or bg[3]} end
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
    self.info_text = nil
  end

  if self.selected and not self.parent:is(ShopCard) then
    for _, character in ipairs(self.parent.characters) do
      if table.any(character.classes, function(v) return v == self.class end) then
        character:highlight()
      end
    end
  end
end


function ClassIcon:highlight()
  self.highlighted = true
  self.spring:pull(0.2, 200, 10)
end


function ClassIcon:unhighlight()
  self.highlighted = false
  self.spring:pull(0.05, 200, 10)
end
