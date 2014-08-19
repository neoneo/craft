import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function init(required Numeric span) {
		variables._span = span
	}

	public String function view(required Context context) {
		return "column";
	}

	public Any function model(required Context context) {
		return {
			span: variables._span
		};
	}

}