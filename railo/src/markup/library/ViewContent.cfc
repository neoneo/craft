import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function configure(required String view) {
		this.viewObject = this.viewFactory.create(arguments.view)
	}

	public Any function view(required Context context) {
		return this.viewObject;
	}

	public Any function process(required Context context) {
		return arguments.context.parameters;
	}

}