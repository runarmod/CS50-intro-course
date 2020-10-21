--[[
    GD50 2018
    Pong Remake

    pong-12
    "The Resize Update"

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]] -- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push

push = require 'libraries/push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'libraries/class'

-- Ability to use buttons
-- created by drikdrok https://love2d.org/forums/viewtopic.php?t=82155
require("libraries/button")

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- define the start-windowsize
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- define the virtual-windowsize
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- find the ratio
WIDTH_RATIO = WINDOW_WIDTH / VIRTUAL_WIDTH
HEIGHT_RATIO = WINDOW_HEIGHT / VIRTUAL_HEIGHT

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

-- score needed to win
WINNING_SCORE = 7

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()

    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = math.random(2)

    -- initialize player paddles and ball
    player1 = Paddle(10, math.random(VIRTUAL_HEIGHT / 5, 4 * VIRTUAL_HEIGHT / 5 - 20), 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, math.random(VIRTUAL_HEIGHT / 5, 4 * VIRTUAL_HEIGHT / 5 - 20), 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- initialize the gameState and default AI is NONE
    gameState = 'start'
    AI = 'NONE'

    -- make the buttons
    button:new(function()
        AI = "NONE"
    end, "NONE", VIRTUAL_WIDTH / 5 * 1 - smallFont:getWidth("NONE") / 2, VIRTUAL_HEIGHT - 30, 0, 0, {0, 0, 0},
        smallFont, {255, 255, 255})

    button:new(function()
        AI = "EASY"
    end, "EASY", VIRTUAL_WIDTH / 5 * 2 - smallFont:getWidth("EASY") / 2, VIRTUAL_HEIGHT - 30, 0, 0, {0, 0, 0},
        smallFont, {255, 255, 255})

    button:new(function()
        AI = "MEDIUM"
    end, "MEDIUM", VIRTUAL_WIDTH / 5 * 3 - smallFont:getWidth("MEDIUM") / 2, VIRTUAL_HEIGHT - 30, 0, 0, {0, 0, 0},
        smallFont, {255, 255, 255})

    button:new(function()
        AI = "HAX"
    end, "HAX", VIRTUAL_WIDTH / 5 * 4 - smallFont:getWidth("HAX") / 2, VIRTUAL_HEIGHT - 30, 0, 0, {0, 0, 0}, smallFont,
        {255, 255, 255})
end

-- RESIZE FUNCTION
-- doesn't work, so won't use
--[[
    Called by LÖVE whenever we resize the screen; here, we just want to pass in the
    width and height to push so our virtual resolution can be resized as needed.
    function love.resize(w, h)
        push:resize(w, h)
    end
]]
    
--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)

    -- required to update the buttons
    updateButtons()

    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        ball.dx = -math.random(140, 200) * (-1) ^ servingPlayer

    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position of collision
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - ball.width / 2 then
            ball.y = VIRTUAL_HEIGHT - ball.width / 2
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- if we reach the left or right edge of the screen, 
        -- go back to start and update the score
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- if we've reached a score of x, the game is over; set the
            -- state to done so we can show the victory message
            if player2Score == WINNING_SCORE then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            -- if we've reached a score of x, the game is over; set the
            -- state to done so we can show the victory message
            if player1Score == WINNING_SCORE then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if AI == 'NONE' then
        -- player 2 movement
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    elseif AI == 'HAX' then
        hax()
    elseif AI == 'EASY' then
        easy()
    elseif AI == 'MEDIUM' then
        medium()
    end
    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
        -- if we press enter during either the start or serve phase, it should
        -- transition to the next appropriate state

    elseif key == 'r' then

        -- game is simply in a restart phase here, but will set the serving
        -- player to the opponent of whomever won for fairness!
        gameState = 'start'
        ball:reset()

        -- reset scores to 0
        player1Score = 0
        player2Score = 0

    elseif key == 'enter' or key == 'return' then

        -- if enter is pressed, go to next gameState

        if gameState == 'start' then
            gameState = 'serve'

        elseif gameState == 'serve' then
            gameState = 'play'

        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            servingPlayer = winningPlayer % 2 + 1

        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()

    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    love.graphics.setFont(smallFont)

    displayScore()

    if gameState == 'start' then

        -- when in startstate, say welcome, instructions to start and show what bot is selected
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Current bot selected: ' .. tostring(AI), 0, 30, VIRTUAL_WIDTH, 'center')

        -- show the buttons for the bot-difficulty
        drawButtons()

    elseif gameState == 'serve' then

        -- when in servestate, say who is serving and give instructions to start
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then

        -- no UI messages to display in play

    elseif gameState == 'done' then

        -- when in donestate, show who wins, instructions to start and show what bot is selected
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Current bot selected: ' .. tostring(AI), 0, 40, VIRTUAL_WIDTH, 'center')

        drawButtons()

    end

    -- show the paddles and ball on the screen
    player1:render()
    player2:render()
    ball:render()

    -- display the fps
    displayFPS()

    push:apply('end')
end

--[[
    Renders the current FPS.
]]
function displayFPS()

    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)

end

--[[
    Simply draws the score to the screen.
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50 - scoreFont:getWidth(tostring(player1Score)) / 2,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 50 - scoreFont:getWidth(tostring(player1Score)) / 2,
        VIRTUAL_HEIGHT / 3)
end

-- hax is imposible to beat
-- paddle will always be at the y position to the ball
function hax()
    player2.y = ball.y + ball.height / 2 - player2.height / 2
end

-- medium is medium hard
-- paddle will try to be where the y to the ball is, but slowed
function medium()
    limitedSpeed(200 / 3)
end

-- easy is easy to win over
-- paddle will try to be where the y to the ball is, but slowed a lot
function easy()
    limitedSpeed(171 / 3)
end

-- get the paddle to the y position to the ball, but not at the full speed of what paddle is capable of
function limitedSpeed(speed)
    if ball.y + ball.height / 2 > player2.y + player2.height / 2 then
        player2.dy = speed
    elseif ball.y + ball.height / 2 < player2.y + player2.height / 2 then
        player2.dy = -speed
    else
        player2.dy = 0
    end
end
