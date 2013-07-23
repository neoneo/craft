component implements="PathSegment" {

	public Numeric function match(required Array path) {
		return arguments.path.len()
	}

}