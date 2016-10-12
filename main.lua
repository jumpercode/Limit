-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local puntos = 0
local tiempo = 0
local inicio = 0
local cerezas = 0
local fresas = 0

local akeys = {up=true, down=true, right=true, left=true}
local keys = {up=false, down=false, right=false, left=false}

local muros = require("src.maps.muros")
local maker = require("src.tool.maker")
local mapa = maker:loadMap(muros)
local frutas = require("src.maps.frutas")
local ip = "res/img/"

local fondo = display.newImageRect( ip.."fo.png", 800, 600 )
fondo.x = 400
fondo.y = 300

local imur = {}
for i,v in ipairs(mapa) do -- Cada fila
    for j,w in ipairs(v) do -- Cada columna
        if(w == "#") then
            local tmp = display.newImageRect(ip.."mu.png", 40, 40)
            tmp.x = ((j-1)*40)+20
            tmp.y = ((i-1)*40)+20
            table.insert( imur, tmp )
        end
    end
end

for k,v in pairs(frutas) do
    local pos = maker:split(k, "_")
    pos[1] = tonumber(pos[1])
    pos[2] = tonumber(pos[2])

    local tmp = nil
    if(v == "C") then
        tmp = display.newImageRect(ip.."ce.png", 20, 20)
        tmp.tipo = "C"
        cerezas = cerezas+1
    elseif(v == "F") then
        tmp = display.newImageRect(ip.."fr.png", 20, 20)
        tmp.tipo = "F"
        fresas = fresas+1
    end

    if(tmp ~= nil) then
        tmp.x = ((pos[1]-1)*40)+20
        tmp.y = ((pos[2]-1)*40)+20
        frutas[k] = tmp
    end
end

local pac = display.newImageRect(ip.."pc.png", 30, 30)
pac.x = 400
pac.y = 300
pac.cx = 0      -- Centro
pac.cy = 0
pac.tlx = 0     -- Esquina Sup Izq
pac.tly = 0
pac.trx = 0     -- Esquina Sup Der
pac.try = 0
pac.blx = 0     -- Esquina Inf Izq
pac.bly = 0
pac.brx = 0     -- Esquina Inf der
pac.bry = 0

debug = display.newText("", 300, 200, 600, 400, native.systemFontBold, 16 )
debug:setFillColor( 1, 1, 1 )

local function calcularLog(pos, des)
    if(des < 0) then
        return math.floor((pos+des)/40)+1
    else
        if(math.mod(pos+des, 40) == 0) then
            return (pos+des)/40
        else
            return math.floor((pos+des)/40)+1
        end
    end
end

local function mover(dir)
    if(dir == "up") then
        t1x = calcularLog(pac.x, -15)
        t1y = calcularLog(pac.y, -20)
        t2x = calcularLog(pac.x,  15)
        t2y = calcularLog(pac.y, -20)
    elseif(dir == "down") then
        t1x = calcularLog(pac.x, -15)
        t1y = calcularLog(pac.y,  20)
        t2x = calcularLog(pac.x,  15)
        t2y = calcularLog(pac.y,  20)
    elseif(dir == "left") then
        t1x = calcularLog(pac.x, -20)
        t1y = calcularLog(pac.y, -15)
        t2x = calcularLog(pac.x, -20)
        t2y = calcularLog(pac.y,  15)
    elseif(dir == "right") then
        t1x = calcularLog(pac.x,  20)
        t1y = calcularLog(pac.y, -15)
        t2x = calcularLog(pac.x,  20)
        t2y = calcularLog(pac.y,  15)
    end

    if(mapa[t1y][t1x] == "-" and mapa[t2y][t2x] == "-") then
        return true
    else
        return false
    end
end

local function comer()
    if(frutas[pac.cx.."_"..pac.cy] ~= nil) then
        local tmp = frutas[pac.cx.."_"..pac.cy]

        if(tmp.tipo == "F") then
            fresas = fresas-1
            puntos = puntos+50
        elseif(tmp.tipo == "C") then
            cerezas = cerezas-1
            puntos = puntos+10
        end

        tiempo = maker:round((system.getTimer()-inicio)/1000, 4)
        tmp:removeSelf()
        frutas[pac.cx.."_"..pac.cy] = nil
    end
end

local function logpos()
    debug.text = "PUNTOS: "..puntos.."  ~  TIEMPO: "..tiempo.."    |    Cerezas: "..cerezas.." - Fresas: "..fresas.."\n"
    debug.text = debug.text..pac.x.." "..pac.y.."\n"
    debug.text = debug.text..pac.cx..":"..pac.cy.."\n"
    debug.text = debug.text..pac.tlx..":"..pac.tly.."\n"
    debug.text = debug.text..pac.trx..":"..pac.try.."\n"
    debug.text = debug.text..pac.blx..":"..pac.bly.."\n"
    debug.text = debug.text..pac.brx..":"..pac.bry.."\n"
end

local function actualizarLogPos()
    pac.cx = calcularLog(pac.x, 0)
    pac.cy = calcularLog(pac.y, 0)

    pac.tlx = calcularLog(pac.x, -15)
    pac.tly = calcularLog(pac.y, -15)

    pac.trx = calcularLog(pac.x,  15)
    pac.try = calcularLog(pac.y, -15)

    pac.blx = calcularLog(pac.x, -15)
    pac.bly = calcularLog(pac.y,  15)

    pac.brx = calcularLog(pac.x,  15)
    pac.bry = calcularLog(pac.y,  15)

    logpos()
end

local function onKeyEvent( event )
    if(akeys[event.keyName]) then
        print(event.keyName, event.phase)
        if(event.phase == "down") then

            if(inicio == 0) then
                inicio = system.getTimer()
            end

            keys[event.keyName] = true

        else
            keys[event.keyName] = false
        end
    end
end

local function gameLoop()
    actualizarLogPos()
    comer()

    if(keys.up) then

        if(pac.xScale == -1) then
            pac.rotation = 90
        else
            pac.rotation = 270
        end

        if mover("up") then
            pac.y = pac.y-5
        end
    elseif(keys.down) then

        if(pac.xScale == -1) then
            pac.rotation = 270
        else
            pac.rotation = 90
        end


        if mover("down") then
            pac.y = pac.y+5
        end
    elseif(keys.left) then
        pac.rotation = 0
        pac.xScale = -1
        if mover("left") then
            pac.x = pac.x-5
        end
    elseif(keys.right) then
        pac.rotation = 0
        pac.xScale = 1
        if mover("right") then
            pac.x = pac.x+5
        end
    end
end

Runtime:addEventListener( "key", onKeyEvent )
local gameTimer = timer.performWithDelay(16, gameLoop, 0)
