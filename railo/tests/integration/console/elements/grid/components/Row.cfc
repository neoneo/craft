import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function addChild(required Column child, Column beforeChild) {
		super.addChild(argumentCollection: ArrayToStruct(arguments))
	}

	public Any function view(required Context context) {
		return this.viewRepository.create("row");
	}

	public Any function process(required Context context) {
		return null;
	}

}