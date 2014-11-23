import craft.util.*;

component extends="CollectionSpec" {

	private Collection function createCollection() {
		return new CacheCollection(new ScopeCache())
	}

}