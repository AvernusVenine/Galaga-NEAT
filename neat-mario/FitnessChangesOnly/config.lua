local _M = {}

_M.NeatConfig = {
Filename = "D:/NEAT-Galaga/Galaga-NEAT/neat-mario/FitnessChangesOnly/pool/DP1.State",

Population = 200,
DeltaDisjoint = 2.0,
DeltaWeights = 0.4,
DeltaThreshold = 1.0,
StaleSpecies = 15,
MutateConnectionsChance = 0.25,
PerturbChance = 0.90,
CrossoverChance = 0.75,
LinkMutationChance = 2.0,
NodeMutationChance = 0.50,
BiasMutationChance = 0.40,
StepSize = 0.1,
DisableMutationChance = 0.4,
EnableMutationChance = 0.2,
TimeoutConstant = 500,
MaxNodes = 1000000,
}

_M.ButtonNames = {
		"B",
		"Left",
		"Right",
	}
	
_M.InputSize = 195

_M.Running = false

return _M