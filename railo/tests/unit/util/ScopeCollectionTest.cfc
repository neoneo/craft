import craft.util.*;

component extends="CollectionTestSetup" {

	private Collection function createCollection() {
		return new ScopeCollection()
	}

}