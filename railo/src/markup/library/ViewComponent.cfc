import craft.content.Leaf;

import craft.request.Context;

component extends="Leaf" {

	public void function init(required String view) {
		variables._view = arguments.view
	}

	public String function view(required Context context) {
		return variables._view;
	}

	public Any function model(required Context context) {
		return null;
	}

}