--!strict
--[[
	* Copyright (c) 2025 Tim7775
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]

local function newSymbol(name: string): any
	local symbol = newproxy(true)
	getmetatable(symbol).__tostring = function()
		return "Symbol(" .. name .. ")"
	end
	return symbol
end

local Seed = newSymbol("Seed")
local NumCount = newSymbol("NumCount")
local IntCount = newSymbol("IntCount")
local RNG = newSymbol("RNG")
local seedGenerator = Random.new()
local LUAU_MAX_PRECISE_INT = 2 ^ 53 - 1
local LUAU_MIN_PRECISE_INT = -2 ^ 53 + 1

--[=[
	A wrapper around Roblox's [Random](https://create.roblox.com/docs/reference/engine/datatypes/Random) class
	that enables users to serialize and set the state of the Random object.

	API differences:
	- Added [DebugRandom.deserialize]
	- Added [DebugRandom.fromString]
	- Added [DebugRandom.isDebugRandom]
	- Added property [ClassName](DebugRandom#ClassName)
	- [DebugRandom:__tostring] yields a serialized result instead of "Random"
	- Added [DebugRandom:Serialize]
	- Added [DebugRandom:SetSerializedState]
	- Added [DebugRandom:CopyStateFrom]
	- Added [DebugRandom:CloneRandom]

	Example use:
	Serialize a random number generator's state when an error occurs, so the error can be replicated
	using [DebugRandom:SetSerializedState] and [DebugRandom.deserialize].

	@class DebugRandom
	@__index prototype
]=]
--[=[
	@within DebugRandom
	@prop ClassName "DebugRandom"
	@readonly
	@tag Prototype Property
]=]
local DebugRandom = {}
DebugRandom.interface = {}
DebugRandom.prototype = setmetatable({ ClassName = "DebugRandom" }, {
	__index = function(_, prop)
		error(`{prop} is not a valid member of DebugRandom`)
	end,
})
DebugRandom.metatable = {
	__index = DebugRandom.prototype,
	__newindex = function(_, prop)
		error(`{prop} cannot be assigned to`)
	end,
	__metatable = "The metatable is locked",
}

--[=[
	Returns a new DebugRandom object.

	@within DebugRandom
]=]
function DebugRandom.interface.new(seed: number?): DebugRandom
	if seed == nil then
		seed = seedGenerator:NextInteger(LUAU_MIN_PRECISE_INT, LUAU_MAX_PRECISE_INT)
	elseif seed > LUAU_MAX_PRECISE_INT or seed < LUAU_MIN_PRECISE_INT then
		if not _G.__TESTEZ_RUNNING_TEST__ then
			warn(
				`Seed '{seed}', passed to DebugRandom.new(), clamped to 0. For consistent cross-platform behavior seed should be within the range of [-9007199254740991, 9007199254740991]`
			)
		end
		seed = 0
	end
	local self: { [any]: any } = {
		[Seed] = seed,
		[NumCount] = 0,
		[IntCount] = 0,
		[RNG] = Random.new(seed),
	}
	return setmetatable(self :: {}, DebugRandom.metatable)
end

--[=[
	Deserializes a string into a DebugRandom object. The string should have come from the `DebugRandom:__tostring()` metamethod.

	**Usage:**
	```lua
	local rng = DebugRandom.new()
	print(rng:NextNumber())

	local str = tostring(rng)
	local rngClone = DebugRandom.fromString(str)
	assert(rngClone == rng)
	```

	@within DebugRandom
]=]
function DebugRandom.interface.fromString(data: string): DebugRandom
	local className, seed, numCount, intCount =
		string.match(data, "^(DebugRandom){Seed: (.+), NumCount: (%d+), IntCount: (%d+)}$")
	return DebugRandom.interface.deserialize({
		ClassName = className,
		Seed = tonumber(seed),
		NumCount = tonumber(numCount),
		IntCount = tonumber(intCount),
	} :: SerializedDebugRandom)
end

--[=[
	Returns `true` if `obj` is a DebugRandom.

	@within DebugRandom
	@param obj any
	@return boolean
]=]
function DebugRandom.interface.isDebugRandom(obj: any)
	return type(obj) == "table" and rawget(obj, RNG) ~= nil
end

--[=[
	This metamethod tests for `self` and `other` values to be equal and is used by the operators `==` and `~=`.

	@within DebugRandom
	@method __eq
	@param other DebugRandom
	@return boolean
]=]
function DebugRandom.metatable.__eq(self: DebugRandom, other: DebugRandom)
	return self[RNG] == other[RNG]
end

--[=[
	This metamethod serializes `self` and transforms it into a string.

	@within DebugRandom
	@method __tostring
	@return string
]=]
function DebugRandom.metatable.__tostring(self: DebugRandom)
	if self[Seed] ~= self[Seed] then
		return ("DebugRandom{Seed: nan, NumCount: %*, IntCount: %*}"):format(self[NumCount], self[IntCount])
	end
	--Use string.format to cast seed from a double into a long long, this cast also takes place in Random's constructor.
	return ("DebugRandom{Seed: %d, NumCount: %*, IntCount: %*}"):format(self[Seed], self[NumCount], self[IntCount])
end

--[=[
	Returns a clone of the DebugRandom's internal Random object.

	@within DebugRandom
	@method CloneRandom
	@return Random
]=]
function DebugRandom.prototype.CloneRandom(self: DebugRandom): Random
	return self[RNG]:Clone()
end

--[=[
	Returns a pseudorandom integer uniformly distributed over [min, max].

	@within DebugRandom
	@method NextInteger
	@param min number
	@param max number
	@return number
]=]
function DebugRandom.prototype.NextInteger(self: DebugRandom, min: number, max: number): number
	local int = self[RNG]:NextInteger(min, max)
	--Increment IntCount after calling NextInteger, so errors in NextInteger won't result in an invalid state
	self[IntCount] += 1
	return int
end

--[=[
	Returns a pseudorandom number uniformly distributed over [0, 1).

	@within DebugRandom
	@method NextNumber
	@return number
]=]
type NextNumber = (self: DebugRandom) -> number
--[=[
	Returns a pseudorandom number uniformly distributed over [min, max).

	@within DebugRandom
	@method NextNumber
	@param min number
	@param max number
	@return number
]=]
type NextNumberBounded = (self: DebugRandom, min: number, max: number) -> number
DebugRandom.prototype.NextNumber = function(self: DebugRandom, ...: number): number
	--Handle Random:NextNumber overloads correctly by passing a parameter pack (e.g. throw when called with nil instead of void)
	local num = self[RNG]:NextNumber(...)
	self[NumCount] += 1
	return num
end :: NextNumber & NextNumberBounded

--[=[
	Uniformly shuffles the array part of tb in-place using NextInteger to pick indices. If there are any nil "holes" in the array part of the table, Shuffle throws an error, since shuffling could change the length.

	The hash part of tb is ignored. No metamethods of tb are invoked.

	The shuffle is defined to be a Fisher-Yates shuffle so the number of NextInteger calls is guaranteed to be consistent between engine versions for a given size of table.

	@within DebugRandom
	@method Shuffle
	@param tb table
]=]
function DebugRandom.prototype.Shuffle(self: DebugRandom, tb: { any }): ()
	self[RNG]:Shuffle(tb)
	self[IntCount] += #tb - 1
end

--[=[
	Returns a unit vector with a pseudorandom direction. Vectors returned from this function are uniformly distributed over the unit sphere.

	@within DebugRandom
	@method NextUnitVector
	@return Vector3
]=]
function DebugRandom.prototype.NextUnitVector(self: DebugRandom): Vector3
	local vector = self[RNG]:NextUnitVector()
	self[NumCount] += 1
	return vector
end

--[=[
	Returns a new DebugRandom object with the same state as the original.

	@within DebugRandom
	@method Clone
	@return DebugRandom
]=]
function DebugRandom.prototype.Clone(self: DebugRandom): DebugRandom
	local clone: { [any]: any } = {
		[Seed] = self[Seed],
		[NumCount] = self[NumCount],
		[IntCount] = self[IntCount],
		[RNG] = self[RNG]:Clone(),
	}
	return setmetatable(clone :: {}, DebugRandom.metatable)
end

--[=[
	@within DebugRandom
	@type SerializedDebugRandom {ClassName: "DebugRandom", Seed: number, NumCount: number, IntCount: number,}
]=]
type SerializedDebugRandom = {
	ClassName: "DebugRandom",
	Seed: number,
	NumCount: number,
	IntCount: number,
}

--[=[
	Returns a serialized version of the DebugRandom.

	@within DebugRandom
	@method Serialize
	@return SerializedDebugRandom
]=]
function DebugRandom.prototype.Serialize(self: DebugRandom): SerializedDebugRandom
	return {
		ClassName = "DebugRandom",
		Seed = self[Seed],
		NumCount = self[NumCount],
		IntCount = self[IntCount],
	}
end

--[=[
	Deserializes the data into a DebugRandom object. This data should have come from
	the `DebugRandom:Serialize()` method.

	@within DebugRandom
	@param data SerializedDebugRandom
]=]
function DebugRandom.interface.deserialize(data: SerializedDebugRandom): DebugRandom
	assert(
		type(data) == "table" and rawget(data, "ClassName") == "DebugRandom",
		"Invalid data for deserializing DebugRandom"
	)
	local self: { [any]: any } = {
		[Seed] = data.Seed,
		[NumCount] = data.NumCount,
		[IntCount] = data.IntCount,
		[RNG] = Random.new(data.Seed),
	}
	for _ = 1, data.NumCount do
		self[RNG]:NextNumber()
	end
	for _ = 1, data.IntCount do
		self[RNG]:NextInteger(0, 1)
	end
	return setmetatable(self :: {}, DebugRandom.metatable)
end

--[=[
	Set the DebugRandom's state. This state should have come from
	the `DebugRandom:Serialize()` method.

	@within DebugRandom
	@method SetSerializedState
	@param data SerializedDebugRandom
]=]
function DebugRandom.prototype.SetSerializedState(self: DebugRandom, data: SerializedDebugRandom)
	assert(
		type(data) == "table" and rawget(data, "ClassName") == "DebugRandom",
		"Invalid data for deserializing DebugRandom"
	)
	self[Seed] = data.Seed
	self[NumCount] = data.NumCount
	self[IntCount] = data.IntCount
	self[RNG] = Random.new(data.Seed)
	for _ = 1, data.NumCount do
		self[RNG]:NextNumber()
	end
	for _ = 1, data.IntCount do
		self[RNG]:NextInteger(0, 1)
	end
end

--[=[
	Set the state of the calling DebugRandom to the state of the `other` DebugRandom.

	@within DebugRandom
	@method CopyStateFrom
	@param other DebugRandom
]=]
function DebugRandom.prototype.CopyStateFrom(self: DebugRandom, other: DebugRandom): ()
	assert(DebugRandom.interface.isDebugRandom(other), "param 'other' must be a valid DebugRandom")
	self[Seed] = other[Seed]
	self[NumCount] = other[NumCount]
	self[IntCount] = other[IntCount]
	self[RNG] = other[RNG]:Clone()
end

export type DebugRandom = typeof(DebugRandom.interface.new(100))
return table.freeze(DebugRandom.interface)
