import craft.util.CacheCollection;
import craft.util.ScopeCache;

component extends="CollectionSpec" {

	private Collection function createCollection() {
		return new CacheCollection(new ScopeCache())
	}

}