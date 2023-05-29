# Hitbox

This is a simple hitbox module which uses spatial query to detect hits.
I made this because I couldn't really find a good premade hitbox module and RaycastHitboxV4 wasn't really fitting my melee needs.

Here is a simple guide to use this module:

```lua

local detector = require(game:GetService("ReplicatedStorage").Hitbox)
local hitbox = detector.Construct(workspace.Detector) -- // create new detector with your object

-- // configure hitbox:

hitbox.OverlapParams = "Default" -- // set to custom parameters if you have any.
hitbox.IgnoreList = {workspace.Detector} -- // Sets the FilterDescendantsInstances to this table.
hitbox.MainTarget = "HumanoidRootPart" -- // Actively detects parts named this and returns them if detected.

hitbox:Detect(5)

hitbox.OnDetected:Connect(function(HumanoidRootPart)
	print("Detected!")
end)

```
