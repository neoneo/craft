import craft.core.layout.Context;

import craft.core.util.Branch;

/**
 * Base class for the composite pattern.
 * @abstract
 **/
component implements="Branch,Content" {

	public void function init() {}

	public void function accept(required Visitor visitor) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Boolean function hasParent() {
		return !IsNull(variables.parent)
	}

	public Composite function getParent() {
		if (!hasParent()) {
			Throw("Node has no parent", "NoSuchElementException")
		}
		return variables.parent
	}

	public void function setParent(required Composite parent) {
		variables.parent = arguments.parent
	}

	public Boolean function hasChildren() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Collects data pertaining to the view before rendering.
	 **/
	public Struct function model(required Context context, required Struct parentModel) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}