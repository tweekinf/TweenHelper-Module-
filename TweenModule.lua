--!strict
--[[

--// DESIGNED BY: TweekINF
--// Used for TetraBlox Development

Features:
- Type safe API (full autocomplete support!)
- Present animations (fade, slide, pop, shake, pulse, etc)
- Chainable sequences (:Then)
- Parallell groups (Play more than one tween at once)
- Auto cleanup & cancellation
- Works on any INSTANCE with tweenable properties (2d + 3d)

]]--

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Types

export type EasingConfig = {
	Time: number?,
	Style: Enum.EasingStyle?,
	Direction: Enum.EasingDirection?,
	RepeatCount: number?,
	Reverses: boolean?,
	DelayTime: number?,
}

export type SlideDirection = "Left" | "Right" | "Up" | "Down"

export type TweenHandle = {
	Tween: Tween,
	Instance: Instance,
	Play: (self: TweenHandle) -> TweenHandle,
	Cancel: (self: TweenHandle) -> (),
	Pause: (self: TweenHandle) -> (),
	OnComplete: (self: TweenHandle, callback: (Enum.PlaybackState) -> ()) -> TweenHandle,
	Wait: (self: TweenHandle) -> Enum.PlaybackState,
	Then: (self: TweenHandle, nextFn: () -> TweenHandle?) -> TweenHandle,
}

--// Module

local TweenHelper = {}

local DEFAULT_TIME = 0.25
local DEFAULT_STYLE = Enum.EasingStyle.Quad
local DEFAULT_DIRECTION = Enum.EasingDirection.Out

local DIRECTION_OFFSETS: { [SlideDirection]: Vector2 } = table.freeze({
	Left = Vector2.new(-1, 0),
	Right = Vector2.new(1, 0),
	Up = Vector2.new(0, -1),
	Down = Vector2.new(0, 1),
})

local FADE_PROPERTIES: { [string]: { string } } = table.freeze({
	Frame = table.freeze({ "BackgroundTransparency" }),
	ScrollingFrame = table.freeze({ "BackgroundTransparency" }),
	ImageLabel = table.freeze({ "BackgroundTransparency", "ImageTransparency" }),
	ImageButton = table.freeze({ "BackgroundTransparency", "ImageTransparency" }),
	TextLabel = table.freeze({ "BackgroundTransparency", "TextTransparency" }),
	TextButton = table.freeze({ "BackgroundTransparency", "TextTransparency" }),
})

--// Internal

local TweenHandle = {}
TweenHandle.__index = TweenHandle

local function newHandle(instance: Instance, tween: Tween): TweenHandle
	return (setmetatable({ Tween = tween, Instance = instance }, TweenHandle) :: any) :: TweenHandle
end

function TweenHandle:Play(): TweenHandle
	self.Tween:Play()
	return self
end

function TweenHandle:Cancel(): ()
	self.Tween:Cancel()
end

function TweenHandle:Pause(): ()
	self.Tween:Pause()
end

function TweenHandle:OnComplete(callback: (Enum.PlaybackState) -> ()): TweenHandle
	self.Tween.Completed:Connect(callback)
	return self
end

function TweenHandle:Wait(): Enum.PlaybackState
	return self.Tween.Completed:Wait()
end

function TweenHandle:Then(nextFn: () -> TweenHandle?): TweenHandle
	self.Tween.Completed:Connect(function(state: Enum.PlaybackState)
		if state == Enum.PlaybackState.Completed then
			nextFn()
		end
	end)
	return self
end

--// Helpers

local function buildTweenInfo(config: EasingConfig?): TweenInfo
	local cfg = config or {}
	return TweenInfo.new(
		cfg.Time or DEFAULT_TIME,
		cfg.Style or DEFAULT_STYLE,
		cfg.Direction or DEFAULT_DIRECTION,
		cfg.RepeatCount or 0,
		cfg.Reverses or false,
		cfg.DelayTime or 0
	)
end

function TweenHelper.Create(instance: Instance, properties: { [string]: any }, config: EasingConfig?): TweenHandle
	return newHandle(instance, TweenService:Create(instance, buildTweenInfo(config), properties))
end

local function buildFadeGoal(guiObject: GuiObject, transparency: number): { [string]: number }
	local goal: { [string]: number } = {}
	local properties = FADE_PROPERTIES[guiObject.ClassName]
	if properties then
		for _, propertyName in properties do
			goal[propertyName] = transparency
		end
	end
	return goal
end

--// Presets

function TweenHelper.FadeIn(guiObject: GuiObject, time: number?): TweenHandle
	return TweenHelper.Create(guiObject, buildFadeGoal(guiObject, 0), { Time = time }):Play()
end

function TweenHelper.FadeOut(guiObject: GuiObject, time: number?): TweenHandle
	return TweenHelper.Create(guiObject, buildFadeGoal(guiObject, 1), { Time = time }):Play()
end

local function offsetPosition(position: UDim2, direction: SlideDirection, distance: number): UDim2
	local vector = DIRECTION_OFFSETS[direction]
	return UDim2.new(
		position.X.Scale, position.X.Offset + vector.X * distance,
		position.Y.Scale, position.Y.Offset + vector.Y * distance
	)
end

function TweenHelper.SlideIn(guiObject: GuiObject, direction: SlideDirection, time: number?, distance: number?): TweenHandle
	local targetPosition = guiObject.Position
	guiObject.Position = offsetPosition(targetPosition, direction, distance or 300)
	return TweenHelper.Create(guiObject, { Position = targetPosition }, { Time = time }):Play()
end

function TweenHelper.SlideOut(guiObject: GuiObject, direction: SlideDirection, time: number?, distance: number?): TweenHandle
	local targetPosition = offsetPosition(guiObject.Position, direction, distance or 300)
	return TweenHelper.Create(guiObject, { Position = targetPosition }, { Time = time }):Play()
end

function TweenHelper.Pop(guiObject: GuiObject, time: number?): TweenHandle
	local targetSize = guiObject.Size
	guiObject.Size = UDim2.new(0, 0, 0, 0)
	return TweenHelper.Create(guiObject, { Size = targetSize }, {
		Time = time or 0.35,
		Style = Enum.EasingStyle.Back,
		Direction = Enum.EasingDirection.Out,
	}):Play()
end

function TweenHelper.PopOut(guiObject: GuiObject, time: number?): TweenHandle
	return TweenHelper.Create(guiObject, { Size = UDim2.new(0, 0, 0, 0) }, {
		Time = time or 0.25,
		Style = Enum.EasingStyle.Back,
		Direction = Enum.EasingDirection.In,
	}):Play()
end

function TweenHelper.Pulse(guiObject: GuiObject, scaleMultiplier: number?, time: number?): TweenHandle
	local mult = scaleMultiplier or 1.1
	local baseSize = guiObject.Size
	local largerSize = UDim2.new(
		baseSize.X.Scale * mult, baseSize.X.Offset * mult,
		baseSize.Y.Scale * mult, baseSize.Y.Offset * mult
	)
	return TweenHelper.Create(guiObject, { Size = largerSize }, {
		Time = time or 0.5,
		Style = Enum.EasingStyle.Sine,
		Direction = Enum.EasingDirection.InOut,
		Reverses = true,
		RepeatCount = -1,
	}):Play()
end

function TweenHelper.Shake(instance: GuiObject | BasePart, strength: number?, duration: number?): () -> ()
	local str = strength or 6
	local dur = duration or 0.4
	local isGui = instance:IsA("GuiObject")
	local seed = math.random(0, 10000)
	local startTime = os.clock()

	local originalUDim: UDim2 = isGui and (instance :: GuiObject).Position or nil :: any
	local originalVector: Vector3 = (not isGui) and (instance :: BasePart).Position or nil :: any

	local connection: RBXScriptConnection

	local function stop()
		if connection and connection.Connected then
			connection:Disconnect()
		end
		if isGui then
			(instance :: GuiObject).Position = originalUDim
		else
			(instance :: BasePart).Position = originalVector
		end
	end

	connection = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		if elapsed >= dur then
			stop()
			return
		end

		local falloff = 1 - (elapsed / dur)
		local t = elapsed * 25
		local nx = math.noise(seed, t) * str * falloff
		local ny = math.noise(seed + 50, t) * str * falloff

		if isGui then
			local gui = instance :: GuiObject
			gui.Position = UDim2.new(
				originalUDim.X.Scale, originalUDim.X.Offset + nx,
				originalUDim.Y.Scale, originalUDim.Y.Offset + ny
			)
		else
			local part = instance :: BasePart
			local nz = math.noise(seed + 100, t) * str * falloff
			part.Position = originalVector + Vector3.new(nx, ny, nz) * 0.1
		end
	end)

	return stop
end

--// Sequencing

function TweenHelper.Sequence(steps: { () -> TweenHandle? }): ()
	for _, step in steps do
		local handle = step()
		if handle then
			handle:Wait()
		end
	end
end

function TweenHelper.Parallel(group: { () -> TweenHandle? }): ()
	local handles: { TweenHandle } = {}
	for _, fn in group do
		local handle = fn()
		if handle then
			table.insert(handles, handle)
		end
	end
	for _, handle in handles do
		handle:Wait()
	end
end

return TweenHelper
