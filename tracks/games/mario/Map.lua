--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]
require 'Util'

Map = Class {}

TILE_BRICK = 1
TILE_EMPTY = -1

-- cloud tiles
CLOUD_LEFT = 6
CLOUD_RIGHT = 7

-- bush tiles
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- mushroom tiles
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- jump block
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

-- flagpole tiles
FLAG_BASE = 16
FLAG_POLE = 12
FLAG_TOP = 8

-- not solid
NOT_SOLID = {TILE_EMPTY, CLOUD_LEFT, CLOUD_RIGHT, FLAG_BASE, FLAG_POLE, FLAG_TOP}

-- constructor for our map object
function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.sprites = generateQuads(self.spritesheet, 16, 16)
    self.music = love.audio.newSource('music/music.wav', 'stream')

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 125
    self.mapHeight = 28
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 15

    -- associate player with map
    self.player = Player(self)

    -- timer
    self.gameTime = 0

    self.flagIsDoneLowered = false
    self.endScreenShouldBeShown = false

    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    -- stay clear of the last 16 blocks
    local x = 1
    while x < self.mapWidth - 16 do

        -- 5% chance to generate a cloud
        -- make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then

                -- choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        -- 5% chance to generate a mushroom
        if math.random(20) == 1 then
            -- not possible to spawn inside a mushroom
            if x - 1 ~= self.player.x / self.tileWidth then
                -- not possible to get two mushrooms right besides eachother
                if self:getTile(x - 1, self.mapHeight / 2 - 1) ~= MUSHROOM_BOTTOM then
                    -- left side of pipe
                    self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
                    self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

                    -- creates column of tiles going to bottom of map
                    for y = self.mapHeight / 2, self.mapHeight do
                        self:setTile(x, y, TILE_BRICK)
                    end

                    -- next vertical scan line
                    x = x + 1
                end
            end
            -- 10% chance to generate bush, being sure to generate away from edge
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            -- place bush component and then column of bricks
            self:setTile(x, bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            -- 10% chance to not generate anything, creating a gap
        elseif math.random(10) ~= 1 or x == self.player.x / self.tileWidth or x + 1 == self.player.x / self.tileWidth then
            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- chance to create a block for Mario to hit
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            -- next vertical scan line
            x = x + 1
        else
            -- increment X so we skip two scanlines, creating a 2-tile gap
            x = x + 2
        end
    end

    -- Draw the finish with a stairs with (optional) desired height
    self:drawFinish()

    -- start the background music
    self.music:setLooping(true)
    self.music:setVolume(0.01)
    self.music:play()

    -- flag waving animation
    self.flagAnimation = {}
    self.flagCurrentFrame = nil
    self.flagAnimation = Animation({
        texture = self.spritesheet,
        frames = {
            love.graphics.newQuad(0, 48, 16, 16, self.spritesheet:getDimensions()),
            love.graphics.newQuad(16, 48, 16, 16, self.spritesheet:getDimensions()),
            love.graphics.newQuad(0, 48, 16, 16, self.spritesheet:getDimensions())
        },
        interval = 0.2
    })

    self.flagCurrentFrame = self.flagAnimation:getCurrentFrame()
end

function Map:drawFinish(inputHeight)
    local xPositionStairs = self.mapWidth - 16

    local pyramidHeight = inputHeight or 4

    -- the pyramid
    for i = 1, pyramidHeight do
        for j = 1, pyramidHeight do
            if i <= j then
                self:setTile(self.mapWidth - 13 + j, self.mapHeight / 2 - i, TILE_BRICK)
            end
        end
    end

    -- floor
    for x = self.mapWidth - 15, self.mapWidth do
        for y = self.mapHeight / 2, self.mapHeight do
            self:setTile(x, y, TILE_BRICK)
        end
    end

    -- flag
    local flagBaseY = self.mapHeight / 2 - 1
    flagHeight = 3
    for y = flagBaseY, flagBaseY - flagHeight, -1 do
        local part = FLAG_POLE
        if y == flagBaseY then
            part = FLAG_BASE
        elseif y == flagBaseY - flagHeight then
            part = FLAG_TOP
        end
        self:setTile(self.mapWidth - 3, y, part)
    end

    -- set the flag to be on top of the pole, which can be done with the following formula
    self.flagY = self.mapHeightPixels / 2 - self.tileHeight - (flagHeight + 1) * self.tileHeight
end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT, MUSHROOM_TOP, MUSHROOM_BOTTOM}

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

-- function to update camera offset with delta time
function Map:update(dt)
    self.player:update(dt)

    if not self.endScreenShouldBeShown then
        self.gameTime = self.gameTime + dt
    end

    -- keep camera's X coordinate following the player, preventing camera from
    -- scrolling past 0 to the left and the map's width
    self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
                    math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))

    self.flagAnimation:update(dt)
    self.flagCurrentFrame = self.flagAnimation:getCurrentFrame()

    -- if flag is being lowered, but not done yet
    -- lower it by number of pixels it should move all together divided 
    -- by number of seconds to do so multiplied with time for this frame
    if self.player.flagHasBeenTouched and not self.flagIsDoneLowered then
        self.flagY = self.flagY + dt * (self.tileHeight * 3) / 2
        self.endScreenShouldBeShown = true
    end

    -- if it is down, keep it down, and say that it is down
    if self.flagY > self.mapHeightPixels / 2 - self.tileHeight - (flagHeight + 1) * self.tileHeight + 3 * self.tileHeight then
        self.flagY = self.mapHeightPixels / 2 - self.tileHeight - (flagHeight + 1) * self.tileHeight + 3 * self.tileHeight
        self.flagIsDoneLowered = true
        self.music:play()
    end
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile], (x - 1) * self.tileWidth,
                    (y - 1) * self.tileHeight)
            end
        end
    end

    -- render the flag to the screen
    love.graphics.draw(self.spritesheet, self.flagCurrentFrame, self.mapWidthPixels - 4 * self.tileWidth, self.flagY, 0,
        1, 1, -self.tileWidth / 2, -4)

    -- render the player to the screen
    self.player:render()

    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), self.camX + 10, 10)

    love.graphics.print('TIME: ' .. tostring(string.format("%.3f", self.gameTime)), self.camX + 10, 20)

    if self.endScreenShouldBeShown then
        self.victoryMessage = "CONGRATULATIONS!\nYOU FINISHED THE LEVEL IN " .. string.format("%.3f", self.gameTime) .. " SECONDS!\n\npress enter to restart"
        love.graphics.printf(self.victoryMessage, self.camX + VIRTUAL_WIDTH / 4, 50, 432 / 2, "center")
    end
end
