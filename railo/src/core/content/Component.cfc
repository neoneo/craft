import craft.core.util.ScopeBranchList;

/**
 * @abstract
 **/
component extends="Node" {

	public void function init() {
		super.init()
		variables.children = new ScopeBranchList(this)
	}

	public String function render(required Context context, Struct parentModel = {}) {

		var model = model(arguments.context, arguments.parentModel)
		var result = arguments.context.render(view(arguments.context), model)

		var output = result.output // the rendered output

		if (output contains "[[children]]") {
			var extension = result.extension // the extension corresponding to the output
			var contents = []
			if (hasChildren()) {
				for (var child in getChildren()) {
					contents.append(child.render(arguments.context, model))
				}
			}

			// concatenate the child contents together according to the type this component is returning
			var content = extension.concatenate(contents)
			output = Replace(output, "[[children]]", content)
		}

		return output
	}

	/**
	 * Returns whether the component contains nodes.
	 **/
	public Boolean function hasChildren() {
		return !variables.children.isEmpty()
	}

	public Array function getChildren() {
		return variables.children.toArray()
	}

	/**
	 * Adds a node to this component.
	 **/
	public void function addChild(required Node child, Node beforeChild) {
		variables.children.add(argumentCollection = arguments.toStruct())
	}

	/**
	 * Removes the node from this component.
	 **/
	public void function removeChild(required Node child) {
		variables.children.remove(arguments.child)
	}

	/**
	 * Moves the node to another position among its siblings.
	 * The optional beforeNode argument specifies where to move the node. If beforeNode is null, the node is moved to the end.
	 **/
	public void function moveChild(required Node child, Node beforeChild) {
		variables.children.move(argumentCollection = arguments.toStruct())
	}

}