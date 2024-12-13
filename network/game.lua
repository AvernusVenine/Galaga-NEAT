--Notes here
config = require "config"
local _M = {}

function _M.loadSprites()
	sprites = {}

	-- Fighter
	sprites[0x00] = 0.1

	-- BOSS SHIP

	-- Boss Ship
	for i=0x1A,0x32 do
		sprites[i] = 1
	end

	-- REGULAR ENEMIES

	-- Butterfly
	for i=0x34,0x4A do
		sprites[i] = 0.6
	end

	-- Bee
	for i=0x4E,0x64 do
		sprites[i] = 0.6
	end

	-- Boss Galaxian
	for i=0x68,0x7B do
		sprites[i] = 0.6
	end

	-- Scorpion
	for i=0x82,0x9A do
		sprites[i] = 0.6
	end

	-- Ray
	for i=0x9C,0xB0 do
		sprites[i] = 0.6
	end

	-- CHALLENGE STAGE ONLY ENEMIES

	-- Dragonfly
	for i=0xB6,0xCA do
		sprites[i] = 0.4
	end

	-- Enterprise
	for i=0xD0,0xE1 do
		sprites[i] = 0.4
	end

	-- Flower
	for i=0xEA,0xF5 do
		sprites[i] = 0.4
	end

end

function _M.getStage()
	local stage = memory.readbyte(0x0482)
	return stage 
end

function _M.getEnemyCount()
	local count = memory.readbyte(0x0494)
	return count
end

function _M.getPosition()
	local shipX = memory.readbyte(0x0014)
	return shipX
end

function _M.getGameMode()
	local mode = memory.readbyte(0x0018)
	return mode
end

function _M.getLives()
	local lives = memory.readbyte(0x0485)
	return lives
end

function _M.getScore()
	local scoreTen = memory.readbyte(0x00E6)
	local scoreHund = memory.readbyte(0x00E5)
	local scoreThous = memory.readbyte(0x00E4)
	local scoreTenThous = memory.readbyte(0x00E3)
	local scoreHundThous = memory.readbyte(0x00E2)
	local scoreMill = memory.readbyte(0x00E1)

	local score = (scoreTen) + (scoreHund * 10) + (scoreThous * 100) + (scoreTenThous * 1000) + (scoreHundThous * 10000) + (scoreMill * 100000)
	return score 
end

function _M.getActives()
	local actives = {}

	local slot = 0
	while slot < 42 do
		local offset = slot * 4

		local status = memory.readbyte(0x0701 + offset)

		if sprites[status] ~= nil then
			spritey = memory.readbyte(0x0700 + offset)
			spritex = memory.readbyte(0x0703 + offset)
			
			local util = memory.readbyte(0x0702 + offset)
			local dir = util & 0x80

			-- Figure out which direction the sprite is going
			if dir == 0x80 then
				dir = -1
			else
				dir = 1
			end

			if sprites[status] == 1 and palette == 2 then
				actives[#actives+1] = {["x"]=spritex + 8, ["y"]=spritey, ["type"]=0.8 * dir}
			else
				actives[#actives+1] = {["x"]=spritex + 8, ["y"]=spritey, ["type"]=sprites[status] * dir}
			end

			slot = slot + 1
		end

		-- Check to see if it is a captured fighter

		local util = memory.readbyte(0x0702)
		local palette = util & 0x03

		if status == 0x00 and palette == 3 then
			spritey = memory.readbyte(0x0700 + offset)
			spritex = memory.readbyte(0x0703 + offset)

			actives[#actives+1] = {["x"]=spritex + 8, ["y"]=spritey, ["type"]=0.2}
			slot = slot + 1
		end

		slot = slot + 1
	end

	return actives
end

function _M.getPassives()
	local passives = {}

	for i = 1, 60 do
		passives[i] = 0
	 end

	for slot=0,3 do
		status = memory.readbyte(0x0403 + slot)

		if status == 1 then
			passives[slot + 5] = 0.8
		end
		if status == 2 then
			passives[slot + 5] = 1
		end
	end

	for slot=0,7 do
		status = memory.readbyte(0x0411 + slot)

		if status == 1 then
			passives[slot + 3 + 12] = 0.6
		end
	end

	for slot=0,7 do
		status = memory.readbyte(0x0421 + slot)

		if status == 1 then
			passives[slot + 3 + 24] = 0.6
		end
	end

	for slot=0,9 do
		status = memory.readbyte(0x0430 + slot)
		
		if status == 1 then
			passives[slot + 2 + 36] = 0.6
		end
	end

	for slot=0,9 do
		status = memory.readbyte(0x0440 + slot)

		if status == 1 then
			passives[slot + 2 + 48] = 0.6
		end
	end

	return passives
end

function _M.getBullets()
	local bullets = {}

	for slot=0,7 do
		local offset = slot * 4

		local status = memory.readbyte(0x0090 + offset)

		if status ~= 128 then
			bulletY = memory.readbyte(0x0091)
			bulletX = memory.readbyte(0x0092)

			bullets[#bullets+1] = {["x"] = bulletX, ["y"] = bulletY}
		end
	end

	return bullets
end

function _M.getInputs()
	_M.loadSprites()

	passives = _M.getPassives()
	actives = _M.getActives()
	bullets = _M.getBullets()
	
	local inputs = {}
	local inputsOffset = {}

	-- Initialize empty
	for i=1,(12 * 14) + 3 do
		inputs[i] = 0
		inputsOffset[i] = 0
	end

	-- Current stage
	stage = _M.getStage()
	inputsOffset[169] = stage

	-- Lives
	lives = _M.getLives()
	inputsOffset[170] = lives

	-- Passive ship state
	state = memory.readbyte(0x049F)
	inputsOffset[171] = state

	-- Passive ships
	for i=1,#passives do
		inputs[i] = passives[i]
	end

	-- Enemy bullets
	for i=1,#bullets do
		local tileX = math.floor(bullets[i]["x"] / 16) + 1
		local tileY = math.floor(bullets[i]["y"] / 16) + 1

		tileX = math.max(1, math.min(tileX, 14))
		tileY = math.max(1, math.min(tileY, 12))

		local index = (tileY - 1) * 14 + tileX

		inputs[index] = 0.5
	end

	-- Active ships
	for i=1,#actives do
		local tileX = math.floor(actives[i]["x"] / 16) + 1
		local tileY = math.floor(actives[i]["y"] / 16) + 1

		tileX = math.max(1, math.min(tileX, 14))
		tileY = math.max(1, math.min(tileY, 12))

		local index = tileY * 14 + tileX

		inputs[index] = actives[i]["type"]
	end

	-- Player Fighter and Offset
	local ship = _M.getPosition()
	local tile = math.floor(ship / 16)
	local offset = 6 - tile

	inputsOffset[12 * 16 + 7] = 1

	-- Apply Offset
	for i=1,(12 * 14) do
		local row = math.floor((i - 1) / 12)
		local col = (i - 1) % 12

		local newCol = col + offset

		if newCol >= 0 and newCol < 12 then
			local index = row * 12 + newCol + 1
			inputsOffset[index] = inputs[i]
		end
	end

	for i=1,(12 * 14) + 3 do
		if inputsOffset[i] == nil then
			inputsOffset[i] = 0
		end
	end

	return inputsOffset
end

function _M.clearJoypad()
	controller = {}
	for b = 1,#config.ButtonNames do
		controller["P1 " .. config.ButtonNames[b]] = false
	end
	joypad.set(controller)
end

return _M