local rings = {}
local stance = 1
local pixies = {
  love.graphics.newImage("img/angie.png"),
  love.graphics.newImage("img/diana.png"),
  love.graphics.newImage("img/carla.png"),
}
local shields = {
  love.graphics.newImage("img/shield_1.png"),
  love.graphics.newImage("img/shield_2.png"),
  love.graphics.newImage("img/shield_3.png"),
}
local bullets = {
  love.graphics.newImage("img/bullet_1.png"),
  love.graphics.newImage("img/bullet_2.png"),
  love.graphics.newImage("img/bullet_3.png"),
}
local bullet_radius = bullets[1]:getWidth() / 2.
local pixie_radius = pixies[1]:getWidth() / 2.
local shield = shields[1]
local pixie = pixies[1]
local window_width = 960
local window_height = 540
local window_center = {480, 270}
local time_acc = 0
local last_ring = 0
local ring_delay = 1.0
local ring_delay_dec = 0.05
local score = 0
local level = 1
local combo = 0
local lives = 3
local bonus = 1
local images = {
  heart = love.graphics.newImage("img/heart.png"),
  background = love.graphics.newImage("img/background.png"),
}
local sounds = {
  good = love.audio.newSource("sfx/good.wav"),
  bad = love.audio.newSource("sfx/bad.wav"),
  levelup = love.audio.newSource("sfx/levelup.wav"),
  gameover = love.audio.newSource("sfx/gameover.wav"),
}

function set_mode(mode)
  if mode == "hard" then
    lines = 1
  elseif mode == "easy" then
    lives = 5
  else
    lives = 3
  end
end

function create_ring ()
  local ring = {polarity = math.random(1, 3)}
  local n = math.random(5, 9)
  local offset = math.random(0, 45)
  local alpha = 360. / n
  for i = 1, n do
    local rad = ((alpha + offset) * math.pi / 180.) * i
    local cx = math.cos(rad) * window_height/2 + window_center[1]
    local cy = math.sin(rad) * window_height/2 + window_center[2]
    local bullet = { img = bullets[ring.polarity],
      cx=x, cy=cy,
      x=cx-bullet_radius,
      y=cy-bullet_radius,
      angle=(rad+math.pi), speed=3 }
    table.insert(ring, bullet)
  end
  return ring
end

function love.load()
  math.randomseed(os.time())
  local mainfont = love.graphics.newFont("font/orange juice 2.0.ttf", 20)
  love.graphics.setFont(mainfont)
  --local music = love.audio.newSource("sfx/acidamine.mp3", "static")
  --love.audio.play(music)
  love.window.setMode(960, 540)
end

function distance (a, b)
  local dx = b[1] - a[1]
  local dy = b[2] - a[2]
  return math.sqrt(dx * dx + dy * dy)
end

function love.update (dt)
  if game_over then
    return
  end
  time_acc = time_acc + dt
  if time_acc > 0.02 then
    time_acc = time_acc - 0.02
    local out = {}
    for _, ring in ipairs(rings) do
      for _, bullet in ipairs(ring) do
        local dx = math.cos(bullet.angle) * bullet.speed
        local dy = math.sin(bullet.angle) * bullet.speed
        bullet.x = bullet.x + dx
        bullet.y = bullet.y + dy
      end
    end
    -- check rings
    local to_remove = {}
    for i, ring in ipairs(rings) do
      local d = distance({ring[1].x, ring[1].y}, window_center)
      if d < pixie_radius then
        table.insert(to_remove, i)
        if ring.polarity == stance then
          love.audio.play(sounds["good"])
          score = score + 100 * level
          combo = combo + 1
          if combo == 10 then
            love.audio.play(sounds["levelup"])
            combo = 0
            level = level + 1
            lives = math.min(lives + 1, 5)
            ring_delay = 1.0 - ring_delay_dec * (level - 1)
          end
        else
          combo = 0
          love.audio.play(sounds["bad"])
          lives = lives - 1
          if lives == 0 then
            love.audio.play(sounds["gameover"])
            game_over = true
          end
        end
      end
    end
    -- remove ring
    for i in ipairs(to_remove) do
      for j in ipairs(rings[i]) do
        table.remove(rings[i], 1)
      end
      table.remove(rings, i)
    end
  end
  last_ring = last_ring + dt
  if last_ring > ring_delay then
    table.insert(rings, create_ring())
    last_ring = last_ring - ring_delay
  end
end

function love.keypressed(key)
  if key == "escape" then
   love.event.quit()
  end
  if key == "left" then
    if stance == 1 then stance = 3 
    else stance = stance - 1 end
  end
  if key == "right" then
    if stance == 3 then stance = 1 
    else stance = stance + 1 end
  end
  pixie = pixies[stance]
  shield = shields[stance]
end

function draw_lives ()
  for i = 1, lives do
    love.graphics.draw(images["heart"], (i-1) * 50, 150)
  end
end

function love.draw()
  love.graphics.draw(images["background"], 0, 0)
  love.graphics.print("Combo   x" .. combo, 0, 0) 
  love.graphics.print("Level   #" .. level, 0, 50)
  love.graphics.print("Score   " .. score, 0, 100) 
  draw_lives()
  love.graphics.draw(shield,
    window_center[1] - pixie_radius,
    window_center[2] - pixie_radius)
  love.graphics.draw(pixie,
    window_center[1] - pixie_radius,
    window_center[2] - pixie_radius)
  for _, ring in ipairs(rings) do
    for _, bullet in ipairs(ring) do
      love.graphics.draw(bullet.img, bullet.x, bullet.y)
    end
  end
end
