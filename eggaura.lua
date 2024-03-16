http.load("https://raw.githubusercontent.com/CluePortal/ZarScriptHelper/main/MoreFunctions.lua")

local calc = 1

local notsaid = true
local mining = false
local C02 = false

local Egg = nil
local setGround = 0

local breaking_block_ticks = 0
local breaking_Egg_ticks = 0
local breaking_render_ticks = 0

local reenable = 0

local function setModuleState(module, state)
    player.message(module_manager.is_module_on(module) ~= state and "."..module or nil)
end

function inRange(x, y, z, range)
    local playerX, playerY, playerZ = player.position()
    local distance = math.sqrt((x - playerX)^2 + (y - playerY)^2 + (z - playerZ)^2)
    return distance <= range
end

function findNearestEgg(radius)
	local startX, startY, startZ = player.position()

	local Egg_blocks = {}

	for x = startX - radius, radius + startX do
		for y = startY - radius, radius + startY do
			for z = startZ - radius, radius + startZ do
				if checkForEgg(x, y, z) then
					local found_Egg_x = math.floor(x)
					local found_Egg_y = math.floor(y)
					local found_Egg_z = math.floor(z)
					table.insert(Egg_blocks, { x = found_Egg_x, y = found_Egg_y, z = found_Egg_z })
				end
			end
		end
	end

	if #Egg_blocks > 0 then
		return { Egg_parts = Egg_blocks, defense = defense }
	else
		return nil
	end
end


function checkForEgg(x, y, z)
	local block = world.block(x, y, z)

	return block ~= nil and block == "tile.skull"
end


function isEggFound()
	return Egg ~= nil
end


function resetNuker()
	setGround = 0
	breaking_block_ticks = 0 
	breaking_Egg_ticks = 0
	breaking_render_ticks = 0
	reenable = 0
	Egg = nil
	sent = true
end

function renderBlockOutline(event, x, y, z)
	local minX, minY, minZ, maxX, maxY, maxZ = renderHelper.getBlockBoundingBox(x, y, z)
	renderHelper.renderOutline(minX, minY, minZ, maxX, maxY, maxZ, event, 225, 37, 70, 255, 5)
end


local block_breaker = {
	on_enable = function()
		resetNuker()
	end,
        
	on_pre_update = function()
        if isEggFound() then
            local found_Egg = findNearestEgg(module_manager.option('EggAura', 'Range'))
            if found_Egg == nil then
                resetNuker()
                return
            end
            Egg = found_Egg
        else
            local found_Egg = findNearestEgg(module_manager.option('EggAura', 'Range'))
            if found_Egg == nil then
                resetNuker()
                return
            end
            Egg = found_Egg
        end
                
                local Egg_position = Egg.Egg_parts[1]
        
                if inRange(Egg_position.x, Egg_position.y, Egg_position.z, module_manager.option('EggAura', 'Range')) then
                    
                    if breaking_Egg_ticks == 0 then
                        player.swing_item()
                        player.send_packet(0x07, 1, Egg_position.x, Egg_position.y, Egg_position.z, 2)
                        sent = true
                    elseif breaking_Egg_ticks >= math.floor(6 * calc) then
                        if module_manager.is_module_on('noslowswords') then
                            player.message('.noslowswords')
                        end
                        reenable = 0
                        player.swing_item()
                        player.send_packet(0x07, 3, Egg_position.x, Egg_position.y, Egg_position.z, 2)
                        sent = true
                        breaking_Egg_ticks = -5
                    end
                    breaking_Egg_ticks = breaking_Egg_ticks + 1
                end
	end,

	on_render_screen = function(e)
		if not isEggFound() then
			return
		end

		local y, color_type
		if module_manager.option("EggAura", "Render Egg outline") then
			local parts = Egg.Egg_parts[1]
			renderBlockOutline(e, parts.x, parts.y, parts.z)
		end
	end
}

module_manager.register('EggAura', block_breaker)
module_manager.register_number('EggAura', 'Range', 3.01, 8.01, 5.5)
module_manager.register_boolean('EggAura', 'Render Egg outline', false)

-- made by nismo1337
