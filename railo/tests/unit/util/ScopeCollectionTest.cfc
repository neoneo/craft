import craft.util.ScopeCollection;

component extends="CollectionSpec" {

	private Collection function createCollection() {
		return new ScopeCollection()
	}

}