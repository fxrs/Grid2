--[[ Created by Grid2 original authors, modified by Michael ]]--

local Tooltip = Grid2.indicatorPrototype:new("tooltip")

local InCombatLockDown = InCombatLockDown

Tooltip.Create = Grid2.Dummy
Tooltip.Layout = Grid2.Dummy

local TooltipCheck= {
	[1] = function() return false end, -- never
	[2] = function() return true  end, -- always
	[3] = InCombatLockdown,            -- in combat
	[4] = function() return not InCombatLockdown() end, -- out of combat
}

local tooltipOOC
local tooltipCheck
local tooltipFrame
local tooltipDisplayed

local function OnFrameEnter(frame)
	local unit = frame.unit
	if unit then
		if tooltipOOC and not InCombatLockdown() then
			Tooltip:Display(unit, Tooltip)
		elseif tooltipCheck() then
			local status = Tooltip:GetCurrentStatus(unit)
			if status then
				Tooltip:Display(unit, status)
			end
		end
	end	
	tooltipFrame = frame
end

local function OnFrameLeave()
	Tooltip:Hide()
	tooltipFrame = nil 
end

-- Special case to get unit info without linking "name" status to the indicator
function Tooltip:GetTooltip(unit, tip)
	tip:SetUnit(unit)
end

function Tooltip:Display(unit, object)
	local anchor = self.dbx.tooltipAnchor
	if anchor then
		GameTooltip:SetOwner(Grid2Layout.frameBack, anchor)
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	end
	object:GetTooltip(unit, GameTooltip)	
	GameTooltip:Show()
	tooltipDisplayed = true
end

function Tooltip:Hide()
	if tooltipDisplayed then
		GameTooltip:Hide()
		tooltipDisplayed = nil
	end
end

function Tooltip:OnUpdate(parent, unit, status)
	if parent == tooltipFrame then
		if status then
			OnFrameEnter(parent)
		else
			Tooltip:Hide()
		end
	end	
end

function Tooltip:OnSuspend()
	Grid2Frame:SetEventHook( 'OnEnter', OnFrameEnter, false )
	Grid2Frame:SetEventHook( 'OnLeave', OnFrameLeave, false )
end

function Tooltip:UpdateDB()
	local dbx  = self.dbx
	local show = dbx.showTooltip or 1
	tooltipOOC = dbx.displayUnitOOC
	tooltipCheck = TooltipCheck[show]
	Grid2Frame:SetEventHook( 'OnEnter', OnFrameEnter, show~=1 or tooltipOOC )
	Grid2Frame:SetEventHook( 'OnLeave', OnFrameLeave, show~=1 or tooltipOOC )
end

local function Create(indicatorKey, dbx)
	Tooltip.dbx = dbx
	Tooltip:UpdateDB()
	Grid2:RegisterIndicator(Tooltip, { "tooltip" })
	return Tooltip
end

Grid2.setupFunc["tooltip"] = Create