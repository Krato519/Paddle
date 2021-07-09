push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()

    love.window.setTitle('Paddle Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font.ttf', 15)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    math.randomseed(os.time())
    
    paddleSound = love.audio.newSource("blast.wav", "static")
    goal = love.audio.newSource("goal.wav", "static")
    final = love.audio.newSource("wins.mp3", "static")
    intro = love.audio.newSource("intro.mp3", "static")

    logo = love.graphics.newImage("logo.jpeg")

    love.graphics.setFont(smallFont)
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = false, 
        vsync = true})   



        
    player1 = Paddle(10, VIRTUAL_HEIGHT/2, 5, 20)    
    player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT/2, 5, 20)

    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    gameState = 'start';
    intro:play()
    --love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { 
        --  fullscreen = false, 
      --  resizable = false,
      --  vsync = true
    --})
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
            intro:stop()
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            love.audio.stop(final)
            intro:play()
            gameState = 'start'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
            --ballX = VIRTUAL_HEIGHT/2 -2;
            --ballY = VIRTUAL_WIDTH/2 -2;
            --ballDX = math.random(2) == 1 and 100 or -100
            --ballDY = math.random(-50, 50)
        end
        
    end 
end

function love.update(dt)

    if gameState == 'serve' then
        if servingPlayer == 1 then
            ball.dx = math.random(100, 150)
        else
            ball.dx = -math.random(100, 150)
        end
        ball.dy = math.random(-50, 50)

    elseif gameState == 'play' then
        
        if gameState == 'play' then
            if ball.y <= 0 then
                ball.y = 0
                ball.dy = -ball.dy
            end

            if ball.y >= VIRTUAL_HEIGHT - 4 then
                ball.y = VIRTUAL_HEIGHT - 4
                ball.dy = -ball.dy
            end
        end

        if ball:collides(player1) then
            
            paddleSound:play()
            ball.dx = -ball.dx * 1.1
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(50, 150)
            else
                ball.dy = math.random(50, 150)    
            end
        end

        if ball:collides(player2) then

            paddleSound:play()
            ball.dx = -ball.dx * 1.1
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(50, 150)
            else
                ball.dy = math.random(50, 150)    
            end
        end
    end

    if ball.x < 0 then
        goal:play()
        player2Score = player2Score + 1
        servingPlayer = 1
        if player2Score == 3 then
            final:play()
            winningPlayer = 2
            gameState = 'done'
        else
            gameState = 'serve'
        end
        ball:reset()
    end

    if ball.x > VIRTUAL_WIDTH then
        goal:play()
        player1Score = player1Score + 1
        servingPlayer = 2
        if player1Score == 3 then
            final:play()
            winningPlayer = 1
            gameState = 'done'
        else
            gameState = 'serve'
        end
        ball:reset()
    end   

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
        --player1Y = math.max(0, player1Y - dt*PADDLE_SPEED)
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
        --player1Y = math.min(VIRTUAL_HEIGHT-20, player1Y + dt*PADDLE_SPEED)
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
        --player2Y = math.max(0, player2Y - dt*PADDLE_SPEED)
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
        --player2Y = math.min(VIRTUAL_HEIGHT-20, player2Y + dt*PADDLE_SPEED)
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
        --ballX = ballX + ballDX * dt
        --ballY = ballY + ballDY * dt
    end

    player1:update(dt)
    player2:update(dt)



end

function love.draw()

    love.graphics.draw(logo,VIRTUAL_WIDTH+65, -60, 0, 0.3, 0.3)

    push:apply("start")
    
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Paddle Pong!', 0, VIRTUAL_HEIGHT/2+40, VIRTUAL_WIDTH+18, 'center')
        love.graphics.printf('PRESS ENTER TO START', 0, VIRTUAL_HEIGHT/2 +60, VIRTUAL_WIDTH+10, 'center')
    elseif gameState == 'serve' then
    love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' serves', 0, VIRTUAL_HEIGHT-20, VIRTUAL_WIDTH+18, 'center')
    elseif gameState == 'play' then

    else
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, VIRTUAL_HEIGHT/2+60, VIRTUAL_WIDTH+10, 'center')
        love.graphics.printf('Press enter to play again', 0, VIRTUAL_HEIGHT/2+80, VIRTUAL_WIDTH+10, 'center')
    end


    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0, 0, 255)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 -125, VIRTUAL_HEIGHT/12)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setColor(255, 0, 0)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 +125, VIRTUAL_HEIGHT/12)
    love.graphics.setColor(255, 255, 255)

    love.graphics.setColor(0, 0, 255)    
    player1:render()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setColor(255, 0, 0)
    player2:render()
    love.graphics.setColor(255, 255, 255)
    ball:render()
    --love.graphics.rectangle('fill', 10, player1Y, 5, 20)
    --love.graphics.rectangle('fill', VIRTUAL_WIDTH-10, player2Y, 5, 20)
    --love.graphics.rectangle('fill', ballY, ballX, 4, 4)
    
    push:apply("end")

end