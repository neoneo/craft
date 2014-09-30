import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function configure(required Boolean fluid) {
		this.viewObject = this.viewFactory.create("bootstrap/view/container", {
			fluid: arguments.fluid
		})
	}

	public Any function view(required Context context) {
		return this.viewObject;
	}

	public Any function process(required Context context) {
		return null;
	}


}