import craft.core.layout.Context;

import craft.core.util.Branch;

/**
 * Base class for the composite pattern.
 * @abstract
 **/
component implements="Branch" {

	public void function init() {}

	public String function render(required Renderer renderer, required Struct baseModel) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Boolean function hasParent() {
		return StructKeyExists(variables, "parent")
	}

	public Composite function getParent() {
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
	public Struct function model(required Context context, required Struct baseModel) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}