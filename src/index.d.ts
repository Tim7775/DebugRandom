declare namespace DebugRandom {
	interface Constructor {
		new (seed: number): DebugRandom;
		new (): DebugRandom;

		/**
		 * Returns `true` if `obj` is a DebugRandom.
		 */
		isDebugRandom: (obj: unknown) => obj is DebugRandom;
		/**
		 * Deserializes the data into a DebugRandom object. This data should have
		 * come from the `DebugRandom:Serialize()` method.
		 */
		deserialize: (data: SerializedDebugRandom) => DebugRandom;
		/**
		 * Deserializes a string into a DebugRandom object. The string should have
		 * come from the `DebugRandom:__tostring()` metamethod.
		 *
		 * **Usage:**
		 * ```ts
		 * const rng = new DebugRandom()
		 * print(rng.NextNumber())
		 *
		 * const str = tostring(rng)
		 * const rngClone = DebugRandom.fromString(str)
		 * ```
		 */
		fromString: (data: string) => DebugRandom;
	}

	interface SerializedDebugRandom {
		ClassName: "DebugRandom";
		Seed: number;
		NumCount: number;
		IntCount: number;
	}
}

interface DebugRandom {
	/**
	 * Returns a pseudorandom integer uniformly distributed over [min, max].
	 */
	NextInteger(this: DebugRandom, min: number, max: number): number;
	/**
	 * Returns a pseudorandom number uniformly distributed over [0, 1).
	 */
	NextNumber(this: DebugRandom): number;
	/**
	 * Returns a pseudorandom number uniformly distributed over [min, max).
	 */
	NextNumber(this: DebugRandom, min: number, max: number): number;
	/**
	 * Uniformly shuffles the array part of `tb` in-place using `NextInteger` to pick indices. If there are any `nil` "holes" in the array part of the table, `Shuffle` throws an error, since shuffling could change the length.
	 *
	 * The hash part of `tb` is ignored. No metamethods are of `tb` are invoked.
	 *
	 * The shuffle is defined to be a Fisher-Yates shuffle so the number of `NextInteger` calls is guaranteed to be consistent between engine versions for a given size of table.
	 */
	Shuffle(this: DebugRandom, tb: Array<unknown>): void;
	/**
	 * Returns a unit vector with a pseudorandom direction.
	 *
	 * Vectors returned from this function are uniformly distributed over the unit sphere.
	 */
	NextUnitVector(this: DebugRandom): Vector3;
	/**
	 * Returns a new DebugRandom object with the same state as the original.
	 */
	Clone(this: DebugRandom): DebugRandom;

	readonly ClassName: "DebugRandom";
	/**
	 * Returns a clone of the DebugRandom's internal Random object.
	 */
	CloneRandom(this: DebugRandom): Random;
	/**
	 * Returns a serialized version of the DebugRandom.
	 */
	Serialize(this: DebugRandom): DebugRandom.SerializedDebugRandom;
	/**
	 * Set DebugRandom's state. This state should have come from
	 * the `DebugRandom:Serialize()` method.
	 */
	SetSerializedState(this: DebugRandom, data: DebugRandom.SerializedDebugRandom): void;
	/**
	 * 	Set the state of the calling DebugRandom to the state of the `other` DebugRandom.
	 */
	CopyStateFrom(this: DebugRandom, other: DebugRandom): void;
}

declare const DebugRandom: DebugRandom.Constructor;
export = DebugRandom;
