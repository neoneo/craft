import craft.core.layout.Leaf;

component extends="Leaf" {

	property String src;

	private String function view(required Context context) {
		return "script";
	}

}