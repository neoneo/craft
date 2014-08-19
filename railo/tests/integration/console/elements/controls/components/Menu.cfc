import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public String function view(required Context context) {
		return "menu";
	}

	public Any function model(required Context context) {
		return null;
	}

}