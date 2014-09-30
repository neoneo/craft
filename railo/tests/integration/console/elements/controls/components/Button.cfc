import craft.content.Leaf;

import craft.request.Context;

component extends="Leaf" {

	private void function configure(required String label) {
		this.label = label
	}

	public Any function view(required Context context) {
		return this.viewFactory.create("button");
	}

	public Any function process(required Context context) {
		return {
			label: this.label
		};
	}

}