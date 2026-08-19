// Intentionally empty.
//
// A binaryTarget cannot declare dependencies or linkerSettings, so this source target
// exists only to carry them: it is what pulls IMA and YouboraLib into a consumer's graph
// and links AppTrackingTransparency and AdSupport. The product exports both this target
// and the binary, so a consumer adds one dependency and gets everything.
