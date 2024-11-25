function love.load()
    wf = require 'Libraries/windfield'
    world = wf.newWorld(0, 0)

    -- loads camera
    camera = require 'Libraries/camera'
    cam = camera()

    -- loads sprite animation
    anim8 = require 'Libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- loads map
    sti = require 'Libraries/sti'
    gameMap = sti('Maps/TestMap.lua')

    -- creates player and animations
    player = {}
    -- x, y, w, h, indent
    player.collider = world:newBSGRectangleCollider(200, 100, 60, 50, 15)
    player.collider:setFixedRotation(true)
    player.x = 200
    player.y = 50
    player.speed = 300
    player.spriteSheet = love.graphics.newImage('sprites/SpriteSheet.png')
    player.grid = anim8.newGrid( 128, 128, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('1-2', 1), 0.2 )
    player.animations.left = anim8.newAnimation( player.grid('1-2', 2), 0.2 )
    player.animations.right = anim8.newAnimation( player.grid('1-2', 3), 0.2 )
    player.animations.up = anim8.newAnimation( player.grid('1-2', 4), 0.2 )

    player.anim = player.animations.down

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)
    -- animation
    local isMoving = false

    local vx = 0
    local vy = 0

    --moves character
    if love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY() - 20

    player.anim:update(dt)

    -- moves camera
    cam:lookAt(player.x, player.y)

    -- stop camera going over map
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- left border
    if cam.x < w/2 then
        cam.x = w/2
    end

    -- top border
    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- right border
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    -- bottom border
    if cam.y >(mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

function love.draw()
    -- draws layers of map and player
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Base"])
        gameMap:drawLayer(gameMap.layers["Trees 1"])
        gameMap:drawLayer(gameMap.layers["Trees 2"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 0.8, nil, 64, 64.5)
        --world:draw()
    cam:detach()
    love.graphics.print("Property of Jan Faulkner, 2023", 10, 10)
end