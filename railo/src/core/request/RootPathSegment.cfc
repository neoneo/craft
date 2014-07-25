component extends="PathSegment" {

	public void function init() {
		super.init()
	}


	public Numeric function match(required String[] path) {
		return arguments.path.isEmpty()
	}

}