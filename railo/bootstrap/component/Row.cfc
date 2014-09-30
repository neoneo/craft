import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function configure() {
		this.viewObject = this.viewFactory.create("bootstrap/view/row");
	}

	public Any function view(required Context context) {
		return this.viewObject;
	}

	public Any function process(required Context context) {
		return null;
	}

}