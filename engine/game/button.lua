
Button = Object:extend()
Button:implement(GameObject)
function Button:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, args.w or (neodgm_font:get_text_width(self.button_text) + 8), neodgm_font.h + 4)
  self.interact_with_mouse = true
  self.text = Text({{text = '[' .. self.fg_color .. ']' .. self.button_text, font = neodgm_font, alignment = 'center'}}, global_text_tags)
end


function Button:update(dt)
  self:update_game_object(dt)
  if main.current.in_credits and not self.credits_button then return end

  if self.hold_button then
    if self.selected and input.m1.pressed then
      self.press_time = love.timer.getTime()
      self.spring:pull(0.2, 200, 10)
    end
    if self.press_time then
      if input.m1.down and love.timer.getTime() - self.press_time > self.hold_button then
        self:action()
        self.press_time = nil
        self.spring:pull(0.1, 200, 10)
      end
    end
    if input.m1.released then
      self.press_time = nil
      self.spring:pull(0.1, 200, 10)
    end
  else
    if self.selected and (input.m1.pressed or input.enter.pressed) then
      if self.action then
        self:action()
      end
    end
    if self.selected and input.m2.pressed then
      if self.action_2 then
        self:action_2()
      end
    end
  end
end


function Button:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    if self.hold_button and self.press_time then
      graphics.set_line_width(5)
      graphics.set_color(fg[-5])
      graphics.arc('open', self.x, self.y, 0.6*self.shape.w, 0, math.remap(love.timer.getTime() - self.press_time, 0, self.hold_button, 0, 1)*2*math.pi)
      graphics.set_line_width(1)
    end
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or _G[self.bg_color][0])
    self.text:draw(self.x, self.y + 1, 0, 1, 1)
  graphics.pop()
end


function Button:set_selected(isSelected)
    if main.current.in_credits and not self.credits_button then return end
    if isSelected then
        ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
        pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.selected = true
        self.text:set_text{{text = '[fgm5]' .. self.button_text, font = neodgm_font, alignment = 'center'}}
        self.spring:pull(0.2, 200, 10)
        if self.mouse_enter then self:mouse_enter() end
    else
        self.selected = false
        self.text:set_text{{text = '[' .. self.fg_color .. ']' .. self.button_text, font = neodgm_font, alignment = 'center'}}
        if self.mouse_exit then self:mouse_exit() end
    end
end


function Button:on_mouse_enter()
    self:set_selected(true)
end


function Button:on_mouse_exit()
    self:set_selected(false)
end


function Button:set_text(text)
  self.button_text = text
  self.text:set_text{{text = '[' .. self.fg_color .. ']' .. self.button_text, font = neodgm_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


SteamFollowButton = Object:extend()
SteamFollowButton:implement(GameObject)
function SteamFollowButton:init(args)
  self:init_game_object(args)
  self.interact_with_mouse = true
  self.shape = Rectangle(self.x, self.y, neodgm_font:get_text_width('follow me on steam!') + 12, neodgm_font.h + 4)
  self.text = Text({{text = '[greenm5]follow me on steam!', font = neodgm_font, alignment = 'center'}}, global_text_tags)
end


function SteamFollowButton:update(dt)
  self:update_game_object(dt)
  if main.current.in_credits then return end

  if self.selected and input.m1.pressed then
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self.spring:pull(0.2, 200, 10)
    self.selected = true
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url'https://store.steampowered.com/dev/a327ex/'
  end
end


function SteamFollowButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or green[0])
    self.text:draw(self.x, self.y)
  graphics.pop()
end


function SteamFollowButton:on_mouse_enter()
  if main.current.in_credits then return end
  love.mouse.setCursor(love.mouse.getSystemCursor'hand')
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]follow me on steam!', font = neodgm_font, alignment = 'center'}}
  self.spring:pull(0.05, 200, 10)
end


function SteamFollowButton:on_mouse_exit()
  if main.current.in_credits then return end
  love.mouse.setCursor()
  self.text:set_text{{text = '[greenm5]follow me on steam!', font = neodgm_font, alignment = 'center'}}
  self.selected = false
end




WishlistButton = Object:extend()
WishlistButton:implement(GameObject)
function WishlistButton:init(args)
  self:init_game_object(args)
  self.interact_with_mouse = true
  if self.w_to_wishlist then
    self.shape = Rectangle(self.x, self.y, 85, 18)
    self.text = Text({{text = '[bg10]w to wishlist', font = neodgm_font, alignment = 'center'}}, global_text_tags)
  else
    self.shape = Rectangle(self.x, self.y, 110, 18)
    self.text = Text({{text = '[bg10]wishlist on steam', font = neodgm_font, alignment = 'center'}}, global_text_tags)
  end
end


function WishlistButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self.spring:pull(0.2, 200, 10)
    self.selected = true
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    system.open_url'https://store.steampowered.com/app/915310/SNKRX/'
  end
end


function WishlistButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1)
  graphics.pop()
end


function WishlistButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  if self.w_to_wishlist then
    self.text:set_text{{text = '[fgm5]w to wishlist', font = neodgm_font, alignment = 'center'}}
  else
    self.text:set_text{{text = '[fgm5]wishlist on steam', font = neodgm_font, alignment = 'center'}}
  end
  self.spring:pull(0.2, 200, 10)
end


function WishlistButton:on_mouse_exit()
  if self.w_to_wishlist then
    self.text:set_text{{text = '[bg10]w to wishlist', font = neodgm_font, alignment = 'center'}}
  else
    self.text:set_text{{text = '[bg10]wishlist on steam', font = neodgm_font, alignment = 'center'}}
  end
  self.selected = false
end




RestartButton = Object:extend()
RestartButton:implement(GameObject)
function RestartButton:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, neodgm_font:get_text_width('restart') + 4, neodgm_font.h + 4)
  self.interact_with_mouse = true
  self.text = Text({{text = '[bg10]NG+' .. tostring(current_new_game_plus), font = neodgm_font, alignment = 'center'}}, global_text_tags)
end


function RestartButton:update(dt)
  if main.current.in_credits then return end
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    main.current.transitioning = true
    ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
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
      system.save_state()
      main:add(BuyScreen'buy_screen')
      system.save_run()
      main:go_to('buy_screen', 1, 0, {}, passives, 1, 0)
    end, text = Text({{text = '[wavy, ' .. tostring(state.dark_transitions and 'fg' or 'bg') .. ']restarting...', font = neodgm_font, alignment = 'center'}}, global_text_tags)}
  end
end


function RestartButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1, 0, 1, 1)
  graphics.pop()
end


function RestartButton:on_mouse_enter()
  if main.current.in_credits then return end
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]NG+' .. tostring(current_new_game_plus), font = neodgm_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


function RestartButton:on_mouse_exit()
  if main.current.in_credits then return end
  self.text:set_text{{text = '[bg10]NG+' .. tostring(current_new_game_plus), font = neodgm_font, alignment = 'center'}}
  self.selected = false
end


GoButton = Object:extend()
GoButton:implement(GameObject)
function GoButton:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 36, 18)
  self.interact_with_mouse = true
  self.text = Text({{text = '[greenm5]시작!', font = neodgm_font, alignment = 'center'}}, global_text_tags)
end


function GoButton:update(dt)
  self:update_game_object(dt)

  if ((self.selected and input.m1.pressed) or input.enter.pressed) and not self.transitioning then
    if #self.parent.units == 0 then
      if not self.info_text then
        error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.info_text = InfoText{group = main.current.ui}
        self.info_text:activate({
          {text = '[fg]cannot start the round with [yellow]0 [fg]units', font = neodgm_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
      end
      self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')

    else
      locked_state = {locked = self.parent.locked, cards = {self.parent.cards[1] and self.parent.cards[1].unit, self.parent.cards[2] and self.parent.cards[2].unit, self.parent.cards[3] and self.parent.cards[3].unit}} 
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.spring:pull(0.2, 200, 10)
      self.selected = true
      ui_switch1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      ui_transition1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.transitioning = true
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
      TransitionEffect{group = main.transitions, x = self.x, y = self.y, color = state.dark_transitions and bg[-2] or character_colors[random:table(self.parent.units).character], transition_action = function()
        main:add(Arena'arena')
        main:go_to('arena', self.parent.level, self.parent.loop, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, self.parent.locked)
      end, text = Text({{text = '[wavy, ' .. tostring(state.dark_transitions and 'fg' or 'bg') .. ']level ' .. tostring(self.parent.level) .. '/' .. tostring(25*(self.parent.loop+1)), font = neodgm_font, alignment = 'center'}}, global_text_tags)}
    end

    if input.enter.pressed then self.selected = false end
  end
end


function GoButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or green[0])
    self.text:draw(self.x, self.y + 1, 0, 1, 1)
  graphics.pop()
end


function GoButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]시작!', font = neodgm_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


function GoButton:on_mouse_exit()
  self.text:set_text{{text = '[greenm5]시작!', font = neodgm_font, alignment = 'center'}}
  self.selected = false
end


LockButton = Object:extend()
LockButton:implement(GameObject)
function LockButton:init(args)
  self:init_game_object(args)
  self.shape = Rectangle(self.x, self.y, 32, 16)
  self.interact_with_mouse = true
  if self.parent.locked then self.shape.w = 44
  else self.shape.w = 32 end
  if self.parent.locked then self.text = Text({{text = '[fgm5]' .. tostring(self.parent.locked and '해제' or '잠금'), font = neodgm_font, alignment = 'center'}}, global_text_tags)
  else self.text = Text({{text = '[bg10]' .. tostring(self.parent.locked and '해제' or '잠금'), font = neodgm_font, alignment = 'center'}}, global_text_tags) end
end


function LockButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    self.parent.locked = not self.parent.locked
    if not self.parent.locked then locked_state = nil end
    if self.parent.locked then
      locked_state = {locked = true, cards = {self.parent.cards[1] and self.parent.cards[1].unit, self.parent.cards[2] and self.parent.cards[2].unit, self.parent.cards[3] and self.parent.cards[3].unit}}
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    end
    ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    self.selected = true
    self.spring:pull(0.2, 200, 10)
    self.text:set_text{{text = '[fgm5]' .. tostring(self.parent.locked and '해제' or '잠금'), font = neodgm_font, alignment = 'center'}}
    if self.parent.locked then self.shape.w = 44
    else self.shape.w = 32 end
  end
end


function LockButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, (self.selected or self.parent.locked) and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1)
  graphics.pop()
end


function LockButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]' .. tostring(self.parent.locked and '해제' or '잠금'), font = neodgm_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
end


function LockButton:on_mouse_exit()
  if not self.parent.locked then self.text:set_text{{text = '[bg10]' .. tostring(self.parent.locked and '해제' or '잠금'), font = neodgm_font, alignment = 'center'}} end
  self.selected = false
end




LevelButton = Object:extend()
LevelButton:implement(GameObject)
function LevelButton:init(args)
  self:init_game_object(args)
  self.interact_with_mouse = true
  self.shape = Rectangle(self.x, self.y, 16, 16)
  self.text = Text({{text = '[bg10]' .. tostring(self.parent.shop_level), font = neodgm_font, alignment = 'center'}}, global_text_tags)
  self.shop_xp = self.parent.shop_xp or 0
  self.max_xp = (self.parent.shop_level == 1 and 3) or (self.parent.shop_level == 2 and 4) or (self.parent.shop_level == 3 and 5) or (self.parent.shop_level == 4 and 6) or (self.parent.shop_level == 5 and 0)
end


function LevelButton:update(dt)
  self:update_game_object(dt)

  if self.selected and input.m1.pressed then
    if self.parent.shop_level >= 5 then return end
    if gold < 5 then
      self.spring:pull(0.2, 200, 10)
      self.selected = true
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      if not self.info_text_2 then
        self.info_text_2 = InfoText{group = main.current.ui}
        self.info_text_2:activate({
          {text = '[fg]gold가 부족합니다.', font = neodgm_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text_2.x, self.info_text_2.y = gw/2, gh/2 + 30
      end
      self.t:after(2, function() self.info_text_2:deactivate(); self.info_text_2.dead = true; self.info_text_2 = nil end, 'info_text_2')
    else
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.shop_xp = self.shop_xp + 1
      if self.shop_xp >= self.max_xp then
        self.shop_xp = 0
        self.parent.shop_level = self.parent.shop_level + 1
        self.max_xp = (self.parent.shop_level == 1 and 3) or (self.parent.shop_level == 2 and 4) or (self.parent.shop_level == 3 and 5) or (self.parent.shop_level == 4 and 6) or (self.parent.shop_level == 5 and 0)
      end
      self.parent.shop_xp = self.shop_xp
      self:create_info_text()
      self.selected = true
      self.spring:pull(0.2, 200, 10)
      gold = gold - 5
      self.parent.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
      self.text = Text({{text = '[bg10]' .. tostring(self.parent.shop_level), font = neodgm_font, alignment = 'center'}}, global_text_tags)
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    end
  end

  if self.selected and input.m2.pressed then
    if self.parent.shop_level <= 1 then return end
    if gold < 10 then
      self.spring:pull(0.2, 200, 10)
      self.selected = true
      error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      if not self.info_text_2 then
        self.info_text_2 = InfoText{group = main.current.ui}
        self.info_text_2:activate({
          {text = '[fg]gold가 부족합니다.', font = neodgm_font, alignment = 'center'},
        }, nil, nil, nil, nil, 16, 4, nil, 2)
        self.info_text_2.x, self.info_text_2.y = gw/2, gh/2 + 30
      end
      self.t:after(2, function() self.info_text_2:deactivate(); self.info_text_2.dead = true; self.info_text_2 = nil end, 'info_text_2')
    else
      ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
      self.shop_xp = 0
      self.parent.shop_level = self.parent.shop_level - 1
      self.max_xp = (self.parent.shop_level == 1 and 3) or (self.parent.shop_level == 2 and 4) or (self.parent.shop_level == 3 and 5) or (self.parent.shop_level == 4 and 6) or (self.parent.shop_level == 5 and 0)
      self.parent.shop_xp = self.shop_xp
      self:create_info_text()
      self.selected = true
      self.spring:pull(0.2, 200, 10)
      gold = gold - 10
      self.parent.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
      self.text = Text({{text = '[bg10]' .. tostring(self.parent.shop_level), font = neodgm_font, alignment = 'center'}}, global_text_tags)
      system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
    end
  end
end


function LevelButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    self.text:draw(self.x, self.y + 1)
    for i = 1, self.max_xp do
      graphics.line(self.x + 0.9*self.shape.w + (i-1)*5, self.y - self.shape.h/3, self.x + 0.9*self.shape.w + (i-1)*5, self.y + self.shape.h/3, bg[1], 2)
    end
    for i = 1, self.shop_xp do
      graphics.line(self.x + 0.9*self.shape.w + (i-1)*5, self.y - self.shape.h/3, self.x + 0.9*self.shape.w + (i-1)*5, self.y + self.shape.h/3, fg[0], 2)
    end
  graphics.pop()
end


function LevelButton:create_info_text()
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil
  if self.parent.shop_level < 5 then
    local t11, t12 = get_shop_odds(self.parent.shop_level, 1), get_shop_odds(self.parent.shop_level+1, 1)
    local t21, t22 = get_shop_odds(self.parent.shop_level, 2), get_shop_odds(self.parent.shop_level+1, 2)
    local t31, t32 = get_shop_odds(self.parent.shop_level, 3), get_shop_odds(self.parent.shop_level+1, 3)
    local t41, t42 = get_shop_odds(self.parent.shop_level, 4), get_shop_odds(self.parent.shop_level+1, 4)
    self.info_text = InfoText{group = main.current.ui}
    self.info_text:activate({
      {text = '[yellow]Lv.' .. self.parent.shop_level .. '[fg] 상점, XP: [yellow]' .. self.shop_xp .. '/' .. self.max_xp .. '[fg], +1 XP 비용: [yellow]5', font = neodgm_font, alignment = 'center', height_multiplier = 1.5},
      {text = '[bg10]상점에 영웅이 등장할 확률', font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
      {text = '[yellow]현재 상점 레밸                  [fgm10]다음 상점 레밸', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[fg]1 티어: ' .. t11 .. '%' .. tostring(t11 < 10 and '  ' or '') .. '                                 [fgm8]1 티어: ' .. t12 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[green]2 티어: ' .. t21 .. '%' .. tostring(t21 < 10 and '  ' or '') .. '                                 [fgm6]2 티어: ' .. t22 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[blue]3 티어: ' .. t31 .. '%' .. tostring(t31 < 10 and '  ' or '') .. '                                 [fgm4]3 티어: ' .. t32 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[purple]4 티어: ' .. t41 .. '%' .. tostring(t41 < 10 and '  ' or '') .. '                                 [fgm2]4 티어: ' .. t42 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
    }, nil, nil, nil, nil, 16, 4, nil, 2)
    self.info_text.x, self.info_text.y = gw/2, gh/2 - 45
  elseif self.parent.shop_level == 5 then
    local t11 = get_shop_odds(self.parent.shop_level, 1)
    local t21 = get_shop_odds(self.parent.shop_level, 2)
    local t31 = get_shop_odds(self.parent.shop_level, 3)
    local t41 = get_shop_odds(self.parent.shop_level, 4)
    self.info_text = InfoText{group = main.current.ui}
    self.info_text:activate({
      {text = '[yellow]Lv.' .. self.parent.shop_level .. '[fg] shop', font = neodgm_font, alignment = 'center', height_multiplier = 1.5},
      {text = '[bg10]chances of units appearing on the shop', font = neodgm_font, alignment = 'center', height_multiplier = 1.25},
      {text = '[yellow]current shop level', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[fg]tier 1: ' .. t11 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[green]tier 2: ' .. t21 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[blue]tier 3: ' .. t31 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
      {text = '[purple]tier 4: ' .. t41 .. '%', font = neodgm_font, alignment = 'left', height_multiplier = 1.25},
    }, nil, nil, nil, nil, 16, 4, nil, 2)
    self.info_text.x, self.info_text.y = gw/2, gh/2 - 45
  end
end


function LevelButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  self.text:set_text{{text = '[fgm5]' .. tostring(self.parent.shop_level), font = neodgm_font, alignment = 'center'}}
  self.spring:pull(0.2, 200, 10)
  self:create_info_text()
end


function LevelButton:on_mouse_exit()
  self.text:set_text{{text = '[bg10]' .. tostring(self.parent.shop_level), font = neodgm_font, alignment = 'center'}}
  self.selected = false
  if self.info_text then
    self.info_text:deactivate()
    self.info_text.dead = true
  end
  self.info_text = nil
end




RerollButton = Object:extend()
RerollButton:implement(GameObject)
function RerollButton:init(args)
  self:init_game_object(args)
  self.interact_with_mouse = true
  if self.parent:is(BuyScreen) then
    self.shape = Rectangle(self.x, self.y, 54, 16)
    self.text = Text({{text = '[bg10]리롤: [yellow]2', font = neodgm_font, alignment = 'center'}}, global_text_tags)
  elseif self.parent:is(Arena) then
    self.shape = Rectangle(self.x, self.y, 60, 16)
    local merchant
    for _, unit in ipairs(self.parent.starting_units) do
      if unit.character == 'merchant' then
        merchant = unit
        break
      end
    end
    if self.parent.level == 3 or (merchant and merchant.level == 3) then
      self.free_reroll = true
      self.text = Text({{text = '[bg10]리롤: [yellow]0', font = neodgm_font, alignment = 'center'}}, global_text_tags)
    else
      self.text = Text({{text = '[bg10]리롤: [yellow]5', font = neodgm_font, alignment = 'center'}}, global_text_tags)
    end
  end
end


function RerollButton:update(dt)
  self:update_game_object(dt)

  if (self.selected and input.m1.pressed) or input.r.pressed then
    if self.parent:is(BuyScreen) then
      if gold < 2 then
        self.spring:pull(0.2, 200, 10)
        self.selected = true
        error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        if not self.info_text then
          self.info_text = InfoText{group = main.current.ui}
          self.info_text:activate({
            {text = '[fg]not enough gold', font = neodgm_font, alignment = 'center'},
          }, nil, nil, nil, nil, 16, 4, nil, 2)
          self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
        end
        self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')
      else
        ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.parent:set_cards(self.parent.shop_level, true)
        self.selected = true
        self.spring:pull(0.2, 200, 10)
        gold = gold - 2
        self.parent.shop_text:set_text{{text = '[wavy_mid, fg]shop [fg]- [fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
        system.save_run(self.parent.level, self.parent.loop, gold, self.parent.units, self.parent.passives, self.parent.shop_level, self.parent.shop_xp, run_passive_pool, locked_state)
      end
    elseif self.parent:is(Arena) then
      if gold < 5 and not self.free_reroll then
        self.spring:pull(0.2, 200, 10)
        self.selected = true
        error1:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        if not self.info_text then
          self.info_text = InfoText{group = main.current.ui, force_update = true}
          self.info_text:activate({
            {text = '[fg]not enough gold', font = neodgm_font, alignment = 'center'},
          }, nil, nil, nil, nil, 16, 4, nil, 2)
          self.info_text.x, self.info_text.y = gw/2, gh/2 + 10
        end
        self.t:after(2, function() self.info_text:deactivate(); self.info_text.dead = true; self.info_text = nil end, 'info_text')
      else
        ui_switch2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
        self.parent:set_passives(true)
        self.selected = true
        self.spring:pull(0.2, 200, 10)
        if not self.free_reroll then gold = gold - 5 end
        self.parent.shop_text:set_text{{text = '[fg, nudge_down]gold: [yellow, nudge_down]' .. gold, font = neodgm_font, alignment = 'center'}}
        self.free_reroll = false
        self.text = Text({{text = '[bg10]리롤: [yellow]5', font = neodgm_font, alignment = 'center'}}, global_text_tags)
      end
    end

    if input.r.pressed then self.selected = false end
  end
end


function RerollButton:draw()
  graphics.push(self.x, self.y, 0, self.spring.x, self.spring.y)
    if self.parent:is(Arena) then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[-2])
    else
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 4, 4, self.selected and fg[0] or bg[1])
    end
    self.text:draw(self.x, self.y + 1)
  graphics.pop()
end


function RerollButton:on_mouse_enter()
  ui_hover1:play{pitch = random:float(1.3, 1.5), volume = 0.5}
  pop2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
  self.selected = true
  if self.parent:is(BuyScreen) then
    self.text:set_text{{text = '[fgm5]리롤: 2', font = neodgm_font, alignment = 'center'}}
  elseif self.parent:is(Arena) then
    if self.free_reroll then
      self.text:set_text{{text = '[fgm5]리롤: 0', font = neodgm_font, alignment = 'center'}}
    else
      self.text:set_text{{text = '[fgm5]리롤: 5', font = neodgm_font, alignment = 'center'}}
    end
  end
  self.spring:pull(0.2, 200, 10)
end


function RerollButton:on_mouse_exit()
  if self.parent:is(BuyScreen) then
    self.text:set_text{{text = '[bg10]리롤: [yellow]2', font = neodgm_font, alignment = 'center'}}
  elseif self.parent:is(Arena) then
    if self.free_reroll then
      self.text:set_text{{text = '[fgm5]리롤: [yellow]0', font = neodgm_font, alignment = 'center'}}
    else
      self.text:set_text{{text = '[fgm5]리롤: [yellow]5', font = neodgm_font, alignment = 'center'}}
    end
  end
  self.selected = false
end