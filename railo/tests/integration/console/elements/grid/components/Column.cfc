import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	private void function configure(required Numeric span) {
		this.span = span
	}

	public Any function view(required Context context) {
		return this.viewRepository.create("column");
	}

	public Any function process(required Context context) {
		return {
			span: this.span
		};
	}

}