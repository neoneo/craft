/**
 * @abstract
 **/
component {

	public Boolean function add(required Any item, Any beforeItem) {

		var added = false
		if (!contains(arguments.item)) {
			if (IsNull(arguments.beforeItem) || contains(arguments.beforeItem)) {
				append(arguments.item)
				added = true
				if (!IsNull(arguments.beforeItem)) {
					move(arguments.item, arguments.beforeItem)
				}
			}
		}

		return added
	}

	public Boolean function move(required Any item, Any beforeItem) {

		var moved = false
		var currentIndex = indexOf(arguments.item)
		// The item must be in the collection already.
		if (currentIndex > 0) {
			if (IsNull(arguments.beforeItem)) {
				if (currentIndex < size()) {
					append(arguments.item)
					moved = true
				}
			} else {
				var newIndex = indexOf(arguments.beforeItem)
				if (newIndex > 0 && newIndex != currentIndex) {
					insertAt(newIndex, arguments.item)
					if (newIndex < currentIndex) {
						currentIndex += 1
					}
					moved = true
				}
			}
			if (moved) {
				deleteAt(currentIndex)
			}
		}

		return moved
	}

	public Boolean function remove(required Any item) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Boolean function contains(required Any item) {
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
	 * Appends the item to the collection. If item is already a member of the collection, item is moved to the end.
	 */
	private void function append(required Any item) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Inserts the item at the given index in the collection. The item must already be a member of the collection.
	 */
	private void function insertAt(required Numeric index, required Any item) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Removes the item at the given index from the collection.
	 */
	private void function deleteAt(required Numeric index) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private void function indexOf(required Any item) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}