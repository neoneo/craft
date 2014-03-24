import craft.core.request.Context;

component {

	public Any function render(required Struct model, required String method) {
		return this[arguments.method](arguments.model)
	}

	/**
	 * Returns the output for a GET request.
	 */
	public Any function get(required Struct model) {
		Throw("Method Not Allowed", "UnsupportedOperationException")
	}

	/**
	 * Returns the output for a POST request.
	 */
	public Any function post(required Struct model) {
		Throw("Method Not Allowed", "UnsupportedOperationException")
	}

	/**
	 * Returns the output for a PUT request.
	 */
	public Any function put(required Struct model) {
		Throw("Method Not Allowed", "UnsupportedOperationException")
	}

	/**
	 * Returns the output for a DELETE request.
	 */
	public Any function delete(required Struct model) {
		Throw("Method Not Allowed", "UnsupportedOperationException")
	}

}