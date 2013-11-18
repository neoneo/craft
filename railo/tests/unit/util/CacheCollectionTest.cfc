import craft.core.util.*;

component extends="CollectionTestSetup" {

	private Collection function createCollection() {
		return new CacheCollection(new ScopeCache())
	}

}