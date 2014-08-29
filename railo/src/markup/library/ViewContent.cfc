import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function init(required String view) {
		this.view = arguments.view
	}

	public String function view(required Context context) {
		return this.view;
	}

	public Any function model(required Context context) {
		return arguments.context.parameters;
	}

}