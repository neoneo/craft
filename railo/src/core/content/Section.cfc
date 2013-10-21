/**
 * Represents an isolated node tree.
 */
component extends="Composite" {

	public void function setParent(required Composite parent) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

	public void function accept(required Visitor visitor) {
		arguments.renderer.visitSection(this)
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

	public String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

	public Struct function model(required Context context, required Struct parentModel) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

}