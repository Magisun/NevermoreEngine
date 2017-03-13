-- Probability.lua
-- @author Quenty, w/ contribs for this...

local lib = {}

function lib.BoxMuller()
	-- Box-Muller Transform
	-- Samples a normal distribution of mean=0, stddev=1 using a uniform random source
	
	return math.sqrt(-2 * math.log(math.random())) * math.cos(2 * math.pi * math.random()) / 2
end

function lib.UnboundedNormalDistribution(Average, StdDeviation)
	-- Samples from a normal distribution with specified mean, and standard deviation
	-- Note: Has no hard cutoffs, see NormalDistribution(...)
	
	return Average + lib.BoxMuller() * StdDeviation
end

function lib.NormalDistribution(Average, StdDeviation, HardMin, HardMax)
	-- Samples from a normal distribution with specified mean, standard deviation, and cutoffs
	-- Output is bounded by HardMin and HardMax
	
	return math.min(HardMax, math.max(HardMin, Average + lib.BoxMuller() * StdDeviation))
end

return lib
