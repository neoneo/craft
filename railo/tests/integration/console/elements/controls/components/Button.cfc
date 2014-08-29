import craft.content.Leaf;

import craft.request.Context;

component extends="Leaf" {

	public void function init(required String label) {
		this.label = label
	}

	public String function view(required Context context) {
		return "button";
	}

	public Any function model(required Context context) {
		return {
			label: this.label
		};
	}

}