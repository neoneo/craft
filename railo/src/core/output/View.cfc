import craft.core.request.Context;

/**
 * The `View` is responsible for rendering the model in any form required. Unlike templates, views can return
 * any datatype so that serialization for the client can be deferred until the last moment. This makes it possible
 * to construct, for example, complex JSON or XML structures without string manipulation.
 */
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

	/**
	 * Returns the output for a PATCH request.
	 */
	public Any function patch(required Struct model) {
		Throw("Method Not Allowed", "UnsupportedOperationException")
	}

}