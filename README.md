# DebugRandom

A wrapper around Roblox's [Random](https://create.roblox.com/docs/reference/engine/datatypes/Random) class that enables users to serialize and set the state of the Random object.

## Usage

**Example use:** Serialize a random number generator's state when an error occurs, so the error can be replicated using [DebugRandom:SetSerializedState](https://tim7775.github.io/DebugRandom/api/DebugRandom#SetSerializedState) or [DebugRandom.deserialize](https://tim7775.github.io/DebugRandom/api/DebugRandom#deserialize).

```lua
local rng = DebugRandom.new()
print(rng:NextNumber())

local state = rng:Serialize()
local deserializedRng = DebugRandom.deserialize(state)
assert(rng == deserializedRng)
assert(rng:NextNumber() == deserializedRng:NextNumber())
```
