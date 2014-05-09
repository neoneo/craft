import craft.core.output.*;

component extends="View" {

	public Any function get(required Struct model) {
		return "get"
	}

	public Any function post(required Struct model) {
		return "post"
	}

	public Any function put(required Struct model) {
		return "put"
	}

	public Any function delete(required Struct model) {
		return "delete"
	}

	public Any function patch(required Struct model) {
		return "patch"
	}

}