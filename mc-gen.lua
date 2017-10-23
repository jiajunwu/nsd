--  Modified from Project Malmo Lua examples
--
-- --------------------------------------------------------------------------------------------------
--  Copyright (c) 2016 Microsoft Corporation
--  
--  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
--  associated documentation files (the "Software"), to deal in the Software without restriction,
--  including without limitation the rights to use, copy, modify, merge, publish, distribute,
--  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--  
--  The above copyright notice and this permission notice shall be included in all copies or
--  substantial portions of the Software.
--  
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
--  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
--  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
--  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- --------------------------------------------------------------------------------------------------

require 'libMalmoLua'
require "socket"

local M = {}

local preXML = [[
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<Mission xmlns="http://ProjectMalmo.microsoft.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <About>
    <Summary>Hello world!</Summary>
  </About>

  <ServerSection>
    <ServerHandlers>
      <FlatWorldGenerator generatorString="3;7,220*1,5*3,2;3;,biome_1"/>
]]

local preDeco = [[
      <DrawingDecorator>
]]
local postDeco = [[
      </DrawingDecorator>
]]

local postXML = [[
      <ServerQuitFromTimeUp timeLimitMs="1000"/>
      <ServerQuitWhenAnyAgentFinishes/>
    </ServerHandlers>
  </ServerSection>

  <AgentSection mode="Survival">
    <Name>MalmoTutorialBot</Name>
    <AgentStart>
      <Placement x="0" y="227" z="0" yaw="90" pitch="0"/>
    </AgentStart>
    <AgentHandlers>
      <ObservationFromFullStats/>
      <ContinuousMovementCommands turnSpeedDegs="180"/>
    </AgentHandlers>
  </AgentSection>
</Mission>
]]

local function malmoRender(xml)
  local function sleep(sec)
    socket.select(nil, nil, sec)
  end
 
  local local_arg = {}
  for i = -5, 0 do
    local_arg[i] = arg[i]
  end

  local agent_host = AgentHost()
  agent_host:addOptionalIntArgument("role,r", "role of this agent", 0)
  local status, err = pcall( function() agent_host:parse( local_arg ) end )
  if not status then
    print('Error parsing command-line arguments: '..err)
    print(agent_host:getUsage())
    os.exit(1)
  end
  if agent_host:receivedArgument("help") then
    print(agent_host:getUsage())
    os.exit(0)
  end

  local my_mission = MissionSpec(xml, true)
  my_mission:forceWorldReset()
  my_mission:setTimeOfDay(6000, false)
  my_mission:timeLimitInSeconds(0.6)
  my_mission:requestVideo(320, 240)

  local my_mission_record = MissionRecordSpec("./saved_data.tgz")
  my_mission_record:recordCommands()
  my_mission_record:recordMP4(20, 400000)
  my_mission_record:recordObservations()

  local client = ClientPool()
  client:add(ClientInfo("127.0.0.1", 10000))   -- replace with the actual server IP

  local role = agent_host:getIntArgument("role")
  local unique_experiment_id = ""
  status, err = pcall(function() agent_host:startMission(my_mission, client, my_mission_record, role, unique_experiment_id) end)
  if not status then
    print("Error starting mission: "..err)
    os.exit(1)
  end

  io.write("Waiting for the mission to start")
  local world_state = agent_host:getWorldState()
  while not world_state.has_mission_begun do
    io.write(".")
    io.flush()
    sleep(0.1)
    world_state = agent_host:getWorldState()
    for error in world_state.errors do
      print("Error: "..error.text)
    end
  end
  io.write("\n")

  -- main loop:
  while world_state.is_mission_running do
    sleep(0.05)
    world_state = agent_host:getWorldState()
    print("video: "..world_state.number_of_video_frames_since_last_state)
    for error in world_state.errors do
      print("Error: "..error.text)
    end

    for frame in world_state.video_frames do
      ti = torch.FloatTensor(frame.channels, frame.height, frame.width) 
      getTorchTensorFromPixels(frame, tonumber(torch.cdata(ti, true)))
      break
    end
  end

  print("Mission has stopped.")
  return torch.div(ti, 255)
end

local function getTreeAXML(xml)
  local x = xml[2]
  local y = xml[4]
  local z = xml[3]

  return string.format('<DrawCuboid x1="%d" x2="%d" y1="227" y2="%d" ' ..
          'z1="%d" z2="%d" type="log"/>', x, x, 229 + y, z, z) ..
         string.format('<DrawCuboid x1="%d" x2="%d" y1="%d" y2="%d" ' ..
          'z1="%d" z2="%d" type="log"/>', x - 1, x + 1, 228 + y, 
          228 + xml[4], z - 1, z + 1) ..
         string.format('<DrawCuboid x1="%d" x2="%d" y1="%d" y2="%d" ' ..
          'z1="%d" z2="%d" type="leaves"/>', x - 1, x + 1, 228 + y, 
          228 + xml[4], z - 2, z + 2) ..
         string.format('<DrawCuboid x1="%d" x2="%d" y1="%d" y2="%d" ' ..
          'z1="%d" z2="%d" type="leaves"/>', x - 2, x + 2, 228 + y,
          228 + xml[4], z - 1, z + 1) ..
         string.format('<DrawCuboid x1="%d" x2="%d" y1="%d" y2="%d" ' ..
          'z1="%d" z2="%d" type="leaves"/>', x - 1, x + 1, 229 + y,
          229 + xml[4], z - 1, z + 1) ..
         string.format('<DrawCuboid x1="%d" x2="%d" y1="%d" y2="%d" ' .. 
          'z1="%d" z2="%d" type="leaves"/>', x, x, 230 + y,
          230 + xml[4], z, z)
end

local function getTreeBXML(xml)
  local x = xml[2]
  local y = xml[4]
  local z = xml[3]

  return string.format('<DrawCuboid x1="%d" x2="%d" y1="227" y2="%d" ' ..
          'z1="%d" z2="%d" type="log"/>', x, x, 230 + y, z, z) ..
         string.format('<DrawSphere x="%d" y="%d" z="%d" radius="2" ' ..
          'type="leaves"/>', x, 230 + y, z) ..
         string.format('<DrawSphere x="%d" y="%d" z="%d" radius="1" ' ..
          'type="log"/>', x, 230 + y, z)
end

local function getObjectXML(xml)
  xml[2] = -1.2 * xml[2]
  xml[3] = 1.2 * xml[2] - 0.15 * xml[2] * xml[3]
  
  local rawXML
  local obj = {"Pig", "Cow", "Sheep", "Chicken", "Wolf", "Horse", 
               "Villager", "ArmorStand", "Boat", "MinecartRideable"}
  
  if xml[1] <= 8 then
    rawXML = string.format('<DrawEntity type="%s" x="%d" y="227" z="%.1f" ' ..
              'yaw="%d" pitch="%d"/>', obj[xml[1]], xml[2], xml[3], xml[5], xml[6])
  elseif xml[1] <= 10 then
    rawXML = string.format('<DrawEntity type="%s" x="%d" y="227" z="%.1f"/>', 
              obj[xml[1]], xml[2], xml[3], xml[5], xml[6])
  elseif xml[1] == 11 then
    rawXML = getTreeAXML(xml)
  elseif xml[1] == 12 then
    rawXML = getTreeBXML(xml)
  end

  return rawXML
end

function M.render(xml)
  local obj = {"Pig", "Cow", "Sheep", "Chicken", "Wolf", "EntityHorse", 
               "Villager", "ArmorStand", "Boat", "Minecart", 
               "LowTree", "TallTree"}
  
  local rawXML = preXML .. preDeco
  for i = 1, xml:size(1) do
    rawXML = rawXML .. getObjectXML(xml[i])
  end
  rawXML = rawXML .. postDeco .. postXML

  return malmoRender(rawXML) 
end

return M
