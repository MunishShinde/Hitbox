--[[

Author: StackUnderflow
-- @05/28/2023

EXAMPLE:

--------------------------------------------------------------------------------------------------------------------------------------------------
  _________ __                 __    ____ ___           .___             _____.__                
 /   _____//  |______    ____ |  | _|    |   \____    __| _/____________/ ____\  |   ______  _  __
 \_____  \\   __\__  \ _/ ___\|  |/ /    |   /    \  / __ |/ __ \_  __ \   __\|  |  /  _ \ \/ \/ /
 /        \|  |  / __ \\  \___|    <|    |  /   |  \/ /_/ \  ___/|  | \/|  |  |  |_(  <_> )     / 
/_______  /|__| (____  /\___  >__|_ \______/|___|  /\____ |\___  >__|   |__|  |____/\____/ \/\_/  
        \/           \/     \/     \/            \/      \/    \/                                 
--------------------------------------------------------------------------------------------------------------------------------------------------

^^^Big name cuz im cool B) (all this documentation crap probably not needed for such a small module)

A small, lightweight hitbox library used to accurately detect collisions.
Draws multiple similarities with "RaycastHitboxV4", it basically served as my reference whilst writing this.

Uses spatial query API (overlap params) every heartbeat to detect hits.
The code below is documented in order to prevent any confusion.
    
Please dm me if there are any issues, i will be replying to all:
[StackUnderflow#6969]
    
]]

-- // HITBOX CLASS:

local hitboxClass = {}

hitboxClass.__index = hitboxClass
hitboxClass.__type = "__HITBOX__"

--------------------------------------------------------------------------------------------------------------------------------------------------

-- // SERVICES & IMPORTS:

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService");

local Signal = require(script.GoodSignal) -- for more information: https://github.com/stravant/goodsignal/

--------------------------------------------------------------------------------------------------------------------------------------------------

--[=[

   @type hitbox

   container which stores all information about a hitbox.
   a hitbox is nothing but the object scaled.

]=]

-- @type or {} hitbox:

-- @index:       _detectionObject         BasePart | Part | MeshPart          The object which will be used as the detector.
-- @index:       _connections             {[UUID]: string = Connection}       All active detection connections of a hitbox.
-- @index:       _returnList              {part1, part2, ...: Part}           All active objects tracked by the detector.

-- @index:       IgnoreList               {Model1, Model2, ...: Model}        All active models who's descendants will be ignored.
-- @index:       OverlapParams            OverlapParams                       OverlapParams of the detector. Custom or Default

--------------------------------------------------------------------------------------------------------------------------------------------------

type hitbox = {
	
	_detectionObject: BasePart | MeshPart | Part;
	_connections: {};
	_returnList: {};
	
	IgnoreList: {};
	OverlapParams: OverlapParams;
	MainTarget: string;
	OnDetected: RBXScriptSignal;
	
}

--------------------------------------------------------------------------------------------------------------------------------------------------

-- @function Construct(): constructs a new hitbox based on the part provided

-- @param:       basePart        BasePart        The part used as reference to generate a hitbox.
-- @param:       size            Vector3         scale of the hitbox relative to the basePart
-- @param:       ignoreList        { }           All active descendants to be ignored. 

--------------------------------------------------------------------------------------------------------------------------------------------------

function hitboxClass.Construct(basePart: BasePart | MeshPart | Part)
	
	assert(basePart, "[ERROR]: Expected class BasePart, received nil")
	
	local self = {
		
		_detectionObject = nil;
		_connections = {};
		_returnList = {};

		IgnoreList = {};
		OverlapParams = nil;
		MainTarget = nil;
		OnDetected = Signal.new(2);
		
	} :: hitbox
	
	-- // set _detectionObject:
	
	self._detectionObject = basePart
	
	setmetatable(self, hitboxClass)
	return self 
	
end

--------------------------------------------------------------------------------------------------------------------------------------------------

--[[

-- @function :Detect(detectionTime: number)
-- @param         detectionTime         integer         Time the hitbox will be active for.

--]]

--------------------------------------------------------------------------------------------------------------------------------------------------

function hitboxClass:Detect(detectionTime: number)
	
	assert(self._detectionObject, "[ERROR]: Expected Part | BasePart | MeshPart, received nil.")
	
	-- // initialize overlap params if nil:
	
	if self.OverlapParams == "Default" or self.OverlapParams == nil then
		
		self.OverlapParams = OverlapParams.new()
		self.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude;
		
		self.OverlapParams.FilterDescendantsInstances = self._ignoreList or {self._detectionObject}
		self.OverlapParams.RespectCanCollide = false;
		
	end	
	
	self._connection = runService.Heartbeat:Connect(function(dt: number)
		
		self._returnList = workspace:GetPartsInPart(self._detectionObject, self.OverlapParams);
		
		if #self._returnList < 0 then return end
		
		for _, v in ipairs(self._returnList) do
			if v.Name == self.MainTarget then

				self.OnDetected:Fire(v)
				self._connection:Disconnect()

			end
		end
	end)
	
	task.delay(detectionTime, function()
		self._connection:Disconnect() -- // schedule disconnect 
	end)
end

--------------------------------------------------------------------------------------------------------------------------------------------------

return hitboxClass
