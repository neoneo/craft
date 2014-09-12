import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function init(required Numeric span) {
		this.span = span
	}

	public String function view(required Context context) {
		return "column";
	}

	public Any function process(required Context context) {
		return {
			span: this.span
		};
	}

}