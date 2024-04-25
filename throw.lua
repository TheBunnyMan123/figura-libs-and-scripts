--https://discord.com/channels/1129805506354085959/1218648783718453359

local ThrowBlockKeybind = keybinds:newKeybind("Throw held block", "key.keyboard.tab", false)
local cmd = "summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}"

ThrowBlockKeybind.press = function()
  local block = player:getHeldItem().id
  local motion = player:getLookDir() * 2
  if block == "minecraft:fire_charge" then
    block = "minecraft:fire_charge"
  elseif block == "minecraft:flint_and_steel" then
    block = "minecraft:fire"   
  end
  if block.find(block, "_spawn_egg") then
    local creature = string.gsub(block, "_spawn_egg", "")
    host:sendChatCommand(cmd.format(cmd,creature, creature, motion.x, motion.y, motion.z)) 
  elseif block == "minecraft:arrow" then
    host:sendChatCommand(cmd.format(cmd, block, block, motion.x, motion.y, motion.z))
  elseif block == "minecraft:tnt" then
    host:sendChatCommand(cmd.format(cmd, "minecraft:tnt", "minecraft:tnt", motion.x, motion.y, motion.z))
  elseif block == "minecraft:fire_charge" then
    host:sendChatCommand(cmd.format(cmd, "minecraft:fireball", block, motion.x, motion.y, motion.z))
  else
    host:sendChatCommand(cmd.format(cmd, "minecraft:falling_block", block, motion.x, motion.y, motion.z))
  end
end
