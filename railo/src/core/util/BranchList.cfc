/**
 * @abstract
 **/
component {

	public void function init(required Branch parent) {
		variables.parent = arguments.parent
	}

	public Branch function getParent() {
		return variables.parent
	}

	public Boolean function add(required Branch child, Branch beforeChild) {

		var added = false
		if (!contains(arguments.child) && !arguments.child.hasParent()) {
			if (IsNull(arguments.beforeChild) || contains(arguments.beforeChild)) {
				arguments.child.setParent(getParent())
				append(arguments.child)
				added = true
				if (!IsNull(arguments.beforeChild)) {
					move(arguments.child, arguments.beforeChild)
				}
			}
		}

		return added
	}

	public Boolean function move(required Branch child, Branch beforeChild) {

		var moved = false
		var currentIndex = indexOf(arguments.child)
		if (currentIndex > 0) {
			var newIndex = IsNull(arguments.beforeChild) ? -1 : indexOf(arguments.beforeChild)
			if (newIndex == -1) {
				append(arguments.child)
				moved = true
			} else if (newIndex > 0 && newIndex != currentIndex) {
				insertAt(newIndex, arguments.child)
				if (newIndex < currentIndex) {
					currentIndex += 1
				}
				moved = true
			}
			if (moved) {
				deleteAt(currentIndex)
			}

		}

		return moved
	}

	public Boolean function remove(required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Boolean function contains(required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Boolean function isEmpty() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Numeric function size() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public any function select(required Function predicate) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Array function toArray() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private void function append(required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private void function insertAt(required Numeric index, required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private void function deleteAt(required Numeric index) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private void function indexOf(required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}