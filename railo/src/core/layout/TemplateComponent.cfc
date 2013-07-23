component extends="Composite" {

	public Composite function setParent(required Composite parent) {
		Throw("Not supported")
	}

	public Array function getPlaceholders() {
		return getPlaceholdersFromNode(this)
	}

	private Array function getPlaceholdersFromNode(required Node node) {

		var regions = []
		if (arguments.node.hasChildren()) {
			arguments.node.getChildren().each(function (child) {
				if (IsInstanceOf(arguments.child, "Placeholder")) {
					regions.append(arguments.child)
				} else {
					regions.append(getPlaceholdersFromNode(arguments.child), true)
				}
			})
		}

		return regions
	}

}