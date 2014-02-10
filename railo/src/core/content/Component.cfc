import craft.core.layout.Context;

/**
 * Base class for the composite pattern.
 *
 * @abstract
 */
component implements="Content" {

	public void function accept(required Visitor visitor) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

	public Boolean function hasParent() {
		return !IsNull(variables._parent)
	}

	public Composite function parent() {
		if (!hasParent()) {
			Throw("Component has no parent", "NoSuchElementException")
		}

		return variables._parent
	}

	public void function setParent(required Composite parent) {
		variables._parent = arguments.parent
	}

	public Boolean function hasChildren() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

	public Struct function model(required Context context, required Struct parentModel) {
		return this[arguments.context.requestMethod() & "Model"](arguments.context, arguments.parentModel)
	}

	public Struct function view(required Context context) {
		return this[arguments.context.requestMethod() & "View"](arguments.context)
	}

	/**
	 * Collects data for a GET request.
	 */
	public Struct function getModel(required Context context, required Struct parentModel) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a POST request.
	 */
	public Struct function postModel(required Context context, required Struct parentModel) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a PUT request.
	 */
	public Struct function putModel(required Context context, required Struct parentModel) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a DELETE request.
	 */
	public Struct function deleteModel(required Context context, required Struct parentModel) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Returns the name of the view for a GET request.
	 */
	public String function getView(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Returns the name of the view for a POST request.
	 */
	public String function postView(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Returns the name of the view for a PUT request.
	 */
	public String function putView(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Returns the name of the view for a DELETE request.
	 */
	public String function deleteView(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}


}