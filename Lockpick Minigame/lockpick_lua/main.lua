local canvas, width, height, degrees, new_degrees, time, color, txtcolor, bgcolor, successColor, streak, maxStreak, targetKey, g_start, g_end, correct, status

function love.load()
    love.graphics.setBackgroundColor(13 / 255, 17 / 255, 23 / 255)
    canvas = love.graphics.newCanvas(300, 300)
    width, height = canvas:getDimensions()
    degrees = 0
    new_degrees = 0
    time = 0
    color = {1, 0, 0}  -- Red color for the needle
    txtcolor = {1, 1, 1}
    bgcolor = {64 / 255, 75 / 255, 88 / 255}
    successColor = {0, 1, 0}  -- Green color for the success area
    streak = 0
    maxStreak = 0
    generateNewTarget()
end

function love.update(dt)
    if degrees >= new_degrees then
        updateStatus('Skipped!')
        processFailure()
        generateNewTarget()
        return
    end
    degrees = degrees + (360 / time) * dt
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setColor(bgcolor)
    drawArc(bgcolor, 10, 100, 0, 2 * math.pi)
    drawSegment(successColor, 10, 100, g_start - math.pi / 2, g_end - math.pi / 2)
    drawNeedle()
    drawKey()
    love.graphics.setCanvas()

    local scale = math.min(love.graphics.getWidth() / canvas:getWidth(), 1)
    love.graphics.draw(canvas, (love.graphics.getWidth() - width * scale) / 2, 50, 0, scale, scale)

    love.graphics.setColor(1, 1, 1)
    local textY = love.graphics.getHeight() - 120
    local textSpacing = 20
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf('Status: ' .. (status or ""), 0, textY, love.graphics.getWidth(), 'center')
    love.graphics.printf('Streak: ' .. streak, 0, textY + textSpacing, love.graphics.getWidth(), 'center')
    love.graphics.printf('Max Streak: ' .. maxStreak, 0, textY + 2 * textSpacing, love.graphics.getWidth(), 'center')
end

function drawArc(color, lineWidth, radius, startAngle, endAngle)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(lineWidth)
    love.graphics.arc('line', width / 2, height / 2, radius, startAngle, endAngle)
end

function drawSegment(color, lineWidth, radius, startAngle, endAngle)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(lineWidth)
    local segments = 100
    local angleStep = (endAngle - startAngle) / segments
    for i = 0, segments - 1 do
        local angle1 = startAngle + i * angleStep
        local angle2 = startAngle + (i + 1) * angleStep
        love.graphics.line(
            width / 2 + radius * math.cos(angle1),
            height / 2 + radius * math.sin(angle1),
            width / 2 + radius * math.cos(angle2),
            height / 2 + radius * math.sin(angle2)
        )
    end
end

function drawNeedle()
    local radians = math.rad(degrees)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(6)  -- Thinner needle
    love.graphics.line(width / 2, height / 2, width / 2 + 100 * math.cos(radians - math.pi / 2), height / 2 + 100 * math.sin(radians - math.pi / 2))
end

function drawKey()
    love.graphics.setColor(txtcolor)
    local fontSize = math.min(width, height) / 3
    love.graphics.setFont(love.graphics.newFont(fontSize))
    local text = tostring(targetKey)
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.printf(text, 0, (height - fontSize) / 2, width, 'center')
end

function love.keypressed(key)
    local validKeys = {'1', '2', '3', '4'}
    if contains(validKeys, key) then
        successColor = {0, 1, 0}  -- Ensure success color is green
        if key == tostring(targetKey) then
            local d_start = math.deg(g_start)
            local d_end = math.deg(g_end)
            if degrees < d_start then
                updateStatus('Too soon!')
                processFailure()
            elseif degrees > d_end then
                updateStatus('Too late!')
                processFailure()
            else
                updateStatus('Success!')
                successColor = {0, 1, 0}
                processSuccess()
            end
        else
            updateStatus('Failed: Pressed ' .. key)
            processFailure()
        end
        correct = true
        generateNewTarget()
    end
end

function updateStatus(message)
    status = message
end

function processSuccess()
    streak = streak + 1
    if streak > maxStreak then
        maxStreak = streak
    end
end

function processFailure()
    if streak > maxStreak then
        maxStreak = streak
    end
    streak = 0
end

function generateNewTarget()
    degrees = 0
    new_degrees = 360
    targetKey = love.math.random(1, 4)
    time = love.math.random(1, 4)  -- Reduce the minimum and maximum time
    g_start = love.math.random() * 2 * math.pi  -- Random start angle between 0 and 2*pi
    local segmentWidth = love.math.random(30, 60)  -- Random segment width between 30 and 60 degrees
    g_end = g_start + math.rad(segmentWidth)
    correct = false
end

function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
