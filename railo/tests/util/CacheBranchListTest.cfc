component extends="BranchListTestSetup" {

	private craft.core.util.BranchList function createBranchList(required craft.core.util.Branch parent) {
		return new craft.core.util.CacheBranchList(arguments.parent, new craft.core.util.ScopeCache())
	}

}