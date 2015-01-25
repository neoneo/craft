import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public Any function view(required Context context) {
		return this.viewRepository.create("menu");
	}

	public Any function process(required Context context) {
		return null;
	}

}