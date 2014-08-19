import craft.content.Leaf;

import craft.request.Context;

component extends="Leaf" {

	public String function view(required Context context) {
		return "logo";
	}

	public Any function model(required Context context) {
		return null;
	}

}