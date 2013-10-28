/**
 * Represents an isolated node tree.
 */
component extends="Composite" {

	/**
	 * @final
	 */
	public void function setParent(required Composite parent) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

	public Struct function model(required Context context, required Struct parentModel) {
		Throw("Function #GetFunctionCalledName()# is not supported", "NotSupportedException")
	}

	public Array function getPlaceholders() {
		return getPlaceholdersFromNode(this)
	}

	private Array function getPlaceholdersFromNode(required Node node) {

		var placeholders = []
		if (arguments.node.hasChildren()) {
			arguments.node.getChildren().each(function (child) {
				if (IsInstanceOf(arguments.child, "Placeholder")) {
					placeholders.append(arguments.child)
				} else {
					placeholders.append(getPlaceholdersFromNode(arguments.child), true)
				}
			})
		}

		return placeholders
	}

}