require 'image'
local dataset = require 'mc-gen'

-- For each object (row),
-- Dim 1: Object ID
-- 1 Pig, 2 Cow, 3 Sheep, 4 Chicken, 5 Wolf, 6 Horse, 7 Villager, 
-- 8 ArmorStand, 9 Boat, 10 MinecartRideable, 11 TreeA, 12 TreeB
-- Dim 2: X (distance to the camera plane)
-- Dim 3: Z (rotation from right to left --- theta) 
-- Dim 4: Height (only for trees, object 11 & 12)
-- Dim 5: Yaw (only for object 1 - 8)
-- Dim 6: Pitch (only for object 1 - 8, currently set to 0 as objects with
-- a nonzero pitch are hard to be captured)
-- Dim 7: Roll (currently ignored, as Malmo/Minecraft doesn't support it)

local xml = torch.Tensor(
  {{1, 3, 4, 0, 330, 0, 0},
   {2, 6, 2, 0, 0, 0, 0},
   {5, 4, 11, 0, 150, 0, 0},
   {6, 5, 5, 0, 30, 0, 0},
   {10, 4, 8, 0, 0, 0, 0},
   {11, 10, 13, 0, 0, 0, 0},
   {11, 11, 10, 2, 0, 0, 0},
   {12, 9, 5, 0, 0, 0, 0},
   {12, 9, 3, 1, 0, 0, 0}}
)

im = dataset.render(xml)
image.save('demo.png', im)
