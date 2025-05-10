# DebugRandom

A wrapper around Roblox's [Random](https://create.roblox.com/docs/reference/engine/datatypes/Random) class that enables users to serialize and set the state of the Random object.

Get it here:

- [Wally](https://wally.run/package/tim7775/debug-random)
- [Releases](https://github.com/Tim7775/DebugRandom/releases)
- [Npm (Roblox-ts)](https://www.npmjs.com/package/@rbxts/debug-random)

<!--moonwave-hide-after-this-line-->

## Documentation

[View Documentation](https://tim7775.github.io/DebugRandom/api/DebugRandom)

<!--moonwave-hide-before-this-line-->

## Usage

**Example use:** Serialize a random number generator's state when an error occurs, so the error can be replicated using [DebugRandom:SetSerializedState](https://tim7775.github.io/DebugRandom/api/DebugRandom#SetSerializedState) or [DebugRandom.deserialize](https://tim7775.github.io/DebugRandom/api/DebugRandom#deserialize).

```lua
local rng = DebugRandom.new()
print(rng:NextNumber())

local state = rng:Serialize()
local deserializedRng = DebugRandom.deserialize(state)
assert(rng == deserializedRng)
assert(rng:NextNumber() == deserializedRng:NextNumber())
assert(rng == DebugRandom.fromString(tostring(rng)))
```
