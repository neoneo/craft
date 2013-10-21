/**
 * @abstract
 **/
component {

	public Boolean function add(required Branch child, Branch beforeChild) {

		var added = false
		if (!arguments.child.hasParent()) {
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
		// Child must be in the collection already.
		if (currentIndex > 0) {
			// The new index is 0 if beforeChild is not found. Use -1 to indicate the end of the collection.
			var newIndex = IsNull(arguments.beforeChild) ? -1 : indexOf(arguments.beforeChild)
			if (newIndex == -1 && currentIndex < size()) {
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

	public Branch function getParent() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
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

	public Any function select(required Function predicate) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Array function toArray() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Appends the child to the collection. If child is already a member of the collection, child is moved to the end.
	 */
	private void function append(required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Inserts the child at the given index in the collection. The child must already be a member of the collection.
	 */
	private void function insertAt(required Numeric index, required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Removes the child at the given index from the collection.
	 */
	private void function deleteAt(required Numeric index) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private void function indexOf(required Branch child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}