/**
 * Represents an isolated node tree.
 */
component extends="Component" {

	public void function setParent(required Component parent) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

	public String function render(required Context context, Struct parentModel) {

		// override this method so that it can render without a view template
		var extension = arguments.context.getExtension()
		var contents = []
		for (var child in getChildren()) {
			contents.append(child.render(arguments.context))
		}

		return extension.concatenate(contents)
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

	private String function view(required Context context) {
		// this method is never called, but is implemented because it is 'abstract'
		return ""
	}

}