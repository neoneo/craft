import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	public void function addChild(required Column child, Column beforeChild) {
		super.addChild(argumentCollection: ArrayToStruct(arguments))
	}

	public String function view(required Context context) {
		return "row";
	}

	public Any function model(required Context context) {
		return null;
	}

}