local K, C, L = unpack(select(2, ...));
if C["nameplate"].enable ~= true then return end

local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]

local numChildren = -1
local frames = {}

local function QueueObject(parent, object)
	parent.queue = parent.queue or {}
	parent.queue[object] = true
end

local function HideObjects(parent)
	for object in pairs(parent.queue) do
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
		else
			object:Hide()
		end
	end
end

local function UpdateThreat(frame)
	if(frame.region:IsShown()) then
		local _, val = frame.region:GetVertexColor()
		if(val > 0.7) then
			self.Health:SetStatusBarColor(2/3, 2/3, 1/4)
		else
			frame.hp:SetStatusBarColor(2/3, 1/4, 1/5)
		end
	else
		frame.hp:SetStatusBarColor(1/6, 1/6, 2/7)
	end
end

local function UpdateObjects(frame)
	frame = frame:GetParent()

	frame.hp:SetHeight(6)
	frame.hp:SetWidth(100)
	frame.hp:ClearAllPoints()
	frame.hp:SetPoint('CENTER', frame)

	frame.name:SetText(frame.oldname:GetText())

	HideObjects(frame)
end

local function UpdateCastbar(frame)
	frame:SetHeight(6)
	frame:SetWidth(100)
	frame:ClearAllPoints()
	frame:SetPoint('TOP', frame:GetParent().hp, 'BOTTOM', 0, -5)

	frame.icon:SetHeight(0.01)
	frame.icon:SetWidth(0.01)

	if(not frame.shield:IsShown()) then
		frame:SetStatusBarColor(1, 0.35, 0.2)
	end
end	

local function SkinObjects(frame)
	local hp, cb = frame:GetChildren()
	local threat, hpborder, cbshield, cbborder, cbicon, overlay, oldname, level, bossicon, raidicon, elite = frame:GetRegions()

	local offset = UIParent:GetScale() / hp:GetEffectiveScale()
	local hpbg = hp:CreateTexture(nil, 'BACKGROUND')
	hpbg:SetPoint('BOTTOMRIGHT', offset, -offset)
	hpbg:SetPoint('TOPLEFT', -offset, offset)
	hpbg:SetTexture(0, 0, 0)

	local hpbg2 = hp:CreateTexture(nil, 'BORDER')
	hpbg2:SetAllPoints(hp)
	hpbg2:SetTexture(1/3, 1/3, 1/3)

	hp:HookScript('OnShow', UpdateObjects)
	hp:SetStatusBarTexture(C["media"].texture)
	frame.hp = hp

	local offset = UIParent:GetScale() / cb:GetEffectiveScale()
	local cbbg = cb:CreateTexture(nil, 'BACKGROUND')
	cbbg:SetPoint('BOTTOMRIGHT', offset, -offset)
	cbbg:SetPoint('TOPLEFT', -offset, offset)
	cbbg:SetTexture(0, 0, 0)

	local cbbg2 = cb:CreateTexture(nil, 'BORDER')
	cbbg2:SetAllPoints(cb)
	cbbg2:SetTexture(1/3, 1/3, 1/3)

	cb.icon = cbicon
	cb.shield = cbshield
	cb:HookScript('OnShow', UpdateCastbar)
	cb:HookScript('OnSizeChanged', UpdateCastbar)
	cb:SetStatusBarTexture(C["media"].texture)
	frame.cb = cb

	local name = hp:CreateFontString(nil, 'OVERLAY')
	name:SetPoint('BOTTOMLEFT', hp, 'TOPLEFT', 0, 2)
	name:SetPoint('BOTTOMRIGHT', hp, 'TOPRIGHT', 0, 2)
	name:SetFont(C["font"].nameplates_font, C["font"].nameplates_font_size * K.noscalemult, C["font"].nameplates_font_style)
	frame.oldname = oldname
	frame.name = name

	QueueObject(frame, threat)
	QueueObject(frame, hpborder)
	QueueObject(frame, cbshield)
	QueueObject(frame, cbborder)
	QueueObject(frame, overlay)
	QueueObject(frame, oldname)
	QueueObject(frame, level)
	QueueObject(frame, bossicon)
	QueueObject(frame, elite)

	UpdateObjects(hp)
	UpdateCastbar(cb)

	frames[frame] = true
end

local select = select
local function HookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()

		if(not frames[frame] and not frame:GetName() and region and region:GetObjectType() == 'Texture' and region:GetTexture() == OVERLAY) then
			SkinObjects(frame)
			frame.region = region
		end
	end
end

CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
	if(WorldFrame:GetNumChildren() ~= numChildren) then
		numChildren = WorldFrame:GetNumChildren()
		HookFrames(WorldFrame:GetChildren())
	end

	-- Threat Color Updates
	if(self.elapsed and self.elapsed > 0.1) then
		for frame in pairs(frames) do
			UpdateThreat(frame)
		end

		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)