import craft.content.Leaf;

import craft.request.Context;

component extends="Leaf" {

	public Any function view(required Context context) {
		return this.viewRepository.create("logo");
	}

	public Any function process(required Context context) {
		return null;
	}

}