import craft.util.ScopeCollection;

component extends="CollectionTest" {

	private Collection function createCollection() {
		return new ScopeCollection()
	}

}