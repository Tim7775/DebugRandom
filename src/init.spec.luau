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

local ITERATION_COUNT = 100
local NUM_LIMITS = table.freeze({
	MAX_BYTE = 0xFF,
	MAX_INT16 = 0x7FFF,
	MAX_INT32 = 0x7FFFFFFF,
	MAX_UINT16 = 0xFFFF,
	MAX_UINT32 = 0xFFFFFFFF,
	MAX_FLOAT32 = (2 - 2 ^ -23) * 2 ^ 127,
	MIN_POSITIVE_VALUE = 2 ^ -1074, --Min. subnormal positive double
	MAX_VALUE = 2 ^ 1023 * (2 - 2 ^ -52), --Max. double
	MIN_SAFE_INTEGER = -2 ^ 53 + 1,
	MAX_SAFE_INTEGER = 2 ^ 53 - 1,
	NEGATIVE_INFINITY = -math.huge,
	POSITIVE_INFINITY = math.huge,
})

local seedGenerator = Random.new()
--SeedCorpus consists of numeric limits, 0 and two different representations of NaN
local seedCorpus = { 0, 0 / 0, tonumber("nan") :: number }
for _, limit in pairs(NUM_LIMITS) do
	table.insert(seedCorpus, limit)
end
table.freeze(seedCorpus)

--Mutate values in seed corpus every run (for now mutate values to just above or below the numeric limit)
local function mutate(value: number)
	return value + 2 - math.random() * 4
end

local function fuzzIt(phrase: string, target: (number) -> (), seed: number?)
	seed = seed or seedGenerator:NextInteger(0, NUM_LIMITS.MAX_INT32)
	getfenv(debug.info(2, "f")).it(`{phrase} - FUZZ<{seed}>`, function()
		math.randomseed(seed :: number)
		for _, value in ipairs(seedCorpus) do
			target(value)
			target(mutate(value))
		end
		local rng = Random.new(seed)
		for _i = 1, ITERATION_COUNT do
			target(rng:NextNumber(NUM_LIMITS.MIN_SAFE_INTEGER, NUM_LIMITS.MAX_SAFE_INTEGER))
		end
	end)
end

return function()
	local DebugRandom = require(script.Parent)

	local function doRandomEquivalentOperation(rng1: DebugRandom.DebugRandom, rng2: DebugRandom.DebugRandom)
		local switch = math.random(1, 2)
		if switch == 1 then
			rng1:NextNumber(1, 3)
			rng2:NextNumber()
		else
			rng1:NextInteger(-math.random(NUM_LIMITS.MAX_INT32), math.random(NUM_LIMITS.MAX_INT32))
			rng2:NextInteger(-math.random(NUM_LIMITS.MAX_INT32), math.random(NUM_LIMITS.MAX_INT32))
		end
	end

	describe("Constructor", function()
		it("should generate unique seeds independent of math.randomseed", function()
			math.randomseed(7775)
			local seed1 = DebugRandom.new():Serialize().Seed
			math.randomseed(7775)
			local seed2 = DebugRandom.new():Serialize().Seed
			expect(seed1).never.to.equal(seed2)
		end)
	end)
	describe("Serialization and deserialization", function()
		fuzzIt("should handle any seed value", function(seedValue)
			local rng1 = DebugRandom.new(seedValue)
			rng1:NextNumber()
			rng1:NextInteger(1, 5)
			local rng2 = DebugRandom.deserialize(rng1:Serialize())
			for _i = 1, math.random(1, 30) do
				doRandomEquivalentOperation(rng1, rng2)
			end
			expect(rng1).to.equal(rng2)
			expect(rng1:NextNumber() == rng2:NextNumber()).to.equal(true)
			expect(rng1:NextInteger(1, 999999) == rng2:NextInteger(1, 999999)).to.equal(true)
		end)
		fuzzIt("should not be thrown off by errors in the Random object's methods", function(seedValue)
			local rng1 = DebugRandom.new(seedValue)
			rng1:NextNumber()
			expect(function()
				rng1:NextNumber("error" :: any, "error" :: any)
			end).to.throw()
			expect(function()
				rng1:NextInteger("error" :: any, "error" :: any)
			end).to.throw()
			expect(function()
				rng1:NextInteger("error" :: any, "error" :: any)
			end).to.throw()
			expect(function()
				rng1:Shuffle({ 1, 2, nil, 4 })
			end).to.throw()
			local rng2 = DebugRandom.deserialize(rng1:Serialize())
			expect(rng1).to.equal(rng2)
			expect(rng1:NextNumber() == rng2:NextNumber()).to.equal(true)
			expect(rng1:NextInteger(1, 999999) == rng2:NextInteger(1, 999999)).to.equal(true)
		end)
		fuzzIt("should be capable of string serialization and deserialization", function(seedValue)
			local rng1 = DebugRandom.new(seedValue)
			for _i = 1, math.random(0, 3) do
				rng1:NextNumber()
			end
			for _i = 1, math.random(0, 3) do
				rng1:NextInteger(1, 5)
			end
			local rng2 = DebugRandom.fromString(tostring(rng1))
			for _i = 1, math.random(0, 20) do
				doRandomEquivalentOperation(rng1, rng2)
			end
			expect(rng1).to.equal(rng2)
			expect(rng1:NextNumber() == rng2:NextNumber()).to.equal(true)
			expect(rng1:NextInteger(1, 999999) == rng2:NextInteger(1, 999999)).to.equal(true)
		end)
		fuzzIt("should be cable of setting the state of existing DebugRandom objects", function(seedValue)
			local rng1 = DebugRandom.new(seedValue)
			local rng2 = rng1:Clone()
			for _i = 1, math.random(0, 3) do
				rng1:NextNumber()
			end
			for _i = 1, math.random(0, 3) do
				rng2:NextNumber()
			end
			for _i = 1, math.random(0, 3) do
				rng1:NextInteger(1, 5)
			end
			for _i = 1, math.random(0, 3) do
				rng2:NextInteger(1, 5)
			end
			rng2:SetSerializedState(rng1:Serialize())
			expect(rng1).to.equal(rng2)

			local rng3 = DebugRandom.new()
			rng3:CopyStateFrom(rng2)
			expect(rng2).to.equal(rng3)
			for _i = 1, math.random(1, 10) do
				doRandomEquivalentOperation(rng1, rng3)
			end
			expect(rng2).never.to.equal(rng3)
			expect(rng1).to.equal(rng3)
		end)
	end)
	describe("NextUnitVector", function()
		fuzzIt("should affect internal state in the same way as calling NextNumber", function(seedValue)
			local rng = DebugRandom.new(seedValue)
			local clone = rng:Clone()
			rng:NextUnitVector()
			expect(rng == clone).to.equal(false)
			clone:NextNumber()
			expect(rng == clone).to.equal(true)
			expect(rng:NextNumber() == clone:NextNumber()).to.equal(true)
			expect(rng:NextInteger(1, 999999) == clone:NextInteger(1, 999999)).to.equal(true)
		end)
	end)
	describe("Shuffle", function()
		fuzzIt("should affect internal state in the same way as calling NextInteger #tb-1 times", function(seedValue)
			local rng = DebugRandom.new(seedValue)
			local clone = rng:Clone()
			local tb = table.create(math.random(0, 10), 1)
			rng:Shuffle(tb)
			for _i = 1, #tb - 1 do
				clone:NextInteger(0, 1)
			end
			expect(rng).to.equal(clone)
			expect(rng:NextNumber() == clone:NextNumber()).to.equal(true)
			expect(rng:NextInteger(1, 999999) == clone:NextInteger(1, 999999)).to.equal(true)
		end)
	end)
end
