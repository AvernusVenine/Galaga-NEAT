--Notes here
config = require "config"
local _M = {}

function _M.loadSprites()
	sprites = {}

	-- Fighter
	sprites[0x00] = 1

	-- BOSS SHIP

	-- Boss Ship
	for i=0x1A,0x32 do
		sprites[i] = -5
	end

	-- REGULAR ENEMIES

	-- Butterfly
	for i=0x34,0x4A do
		sprites[i] = -2
	end

	-- Bee
	for i=0x4E,0x64 do
		sprites[i] = -2
	end

	-- Boss Galaxian
	for i=0x68,0x7B do
		sprites[i] = -3
	end

	-- Scorpion
	for i=0x82,0x9A do
		sprites[i] = -3
	end

	-- Ray
	for i=0x9C,0xB0 do
		sprites[i] = -3
	end

	-- CHALLENGE STAGE ONLY ENEMIES

	-- Dragonfly
	for i=0xB6,0xCA do
		sprites[i] = -4
	end

	-- Enterprise
	for i=0xD0,0xE1 do
		sprites[i] = -4
	end

	-- Flower
	for i=0xEA,0xF5 do
		sprites[i] = -4
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
	for slot=0,31 do
		local offset = slot * 8

		local status = memory.readbyte(0x0701 + offset)
		if status ~= 0xFE then
			spritex = memory.readbyte(0x0700 + offset) + 7
			spritey = memory.readbyte(0x0703 + offset)
			
			local util = memory.readbyte(0x0702)
			util = util & 0x03
			
			if sprites[status] == 1 and util == 3 then
				actives[#actives+1] = {["x"]=spritex, ["y"]=spritey, ["type"]=2}
			else
				actives[#actives+1] = {["x"]=spritex, ["y"]=spritey, ["type"]=sprites[status]}
			end
		end
	end

	return actives
end

function _M.getPassives()
	local passives = {}

	for i = 1, 48 do
		passives[i] = 0
	 end

	for slot=0,3 do
		status = memory.readbyte(0x0403 + slot)

		if status == 1 then
			passives[slot + 5] = -9
		end
		if status == 2 then
			passives[slot + 5] = -10
		end
	end

	for slot=0,7 do
		status = memory.readbyte(0x0411 + slot)

		if status == 1 then
			passives[slot + 3] = -1
		end
	end

	for slot=0,7 do
		status = memory.readbyte(0x0421 + slot)

		if status == 1 then
			passives[slot + 3] = -1
		end
	end

	for slot=0,9 do
		status = memory.readbyte(0x0430 + slot)
		
		if status == 1 then
			passives[slot + 2] = -2
		end
	end

	for slot=0,9 do
		status = memory.readbyte(0x0440 + slot)

		if status == 1 then
			passives[slot + 2] = -2
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

	-- Initialize empty
	for i=1,195 do
		inputs[i] = 0
	end

	-- Current stage
	stage = _M.getStage()
	inputs[193] = stage

	-- Lives
	lives = _M.getLives()
	inputs[194] = lives

	-- Passive ship state
	state = memory.readbyte(0x049F)
	inputs[195] = state

	-- Passive ships
	for i=1,#passives do
		inputs[i] = passives[i]
	end

	-- Enemy bullets
	for i=1,#bullets do
		local tileX = math.floor(bullets[i]["x"] / 16)
		local tileY = math.floor(bullets[i]["y"] / 16)

		if tileX > 12 then
			tileX = 12
		end
		if tileY > 15 then
			tileY = 15
		end

		local index = (tileY * 12 + tileX)

		inputs[index] = -1
	end

	-- Active ships
	for i=1,#actives do
		local tileX = math.floor(actives[i]["x"] / 16)
		local tileY = math.floor(actives[i]["y"] / 16)

		if tileX > 12 then
			tileX = 12
		end
		if tileY > 15 then
			tileY = 15
		end

		local index = tileY * 12 + tileX

		inputs[index] = actives["type"]
	end

	for i=1,195 do
		if inputs[i] == nil then
			inputs[i] = 0
		end
	end

	return inputs
end

function _M.clearJoypad()
	controller = {}
	for b = 1,#config.ButtonNames do
		controller["P1 " .. config.ButtonNames[b]] = false
	end
	joypad.set(controller)
end

return _M