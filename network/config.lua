local _M = {}

_M.NeatConfig = {
Filename = "D:/NEAT-Galaga/Galaga-NEAT/network/pool/DP1.State",

Population = 350,
DeltaDisjoint = 2.0,
DeltaWeights = 0.4,
DeltaThreshold = 2.0,
StaleSpecies = 20,
MutateConnectionsChance = 0.25,
PerturbChance = 0.90,
CrossoverChance = 0.75,
LinkMutationChance = 2.0,
NodeMutationChance = 0.50,
BiasMutationChance = 0.40,
StepSize = 0.1,
DisableMutationChance = 0.4,
EnableMutationChance = 0.2,
TimeoutConstant = 1000,
MaxNodes = 1000000,
}

_M.ButtonNames = {
		"B",
		"Left",
		"Right",
	}
	
_M.InputSize = (12 * 14) + 3

_M.Running = false

return _M