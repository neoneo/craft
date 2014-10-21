import craft.markup.*;

import crafttests.unit.markup.stubs.create.*;

component implements="ElementFactory" {

	// Mock the create method of the factory. Regular mocking doesn't allow for creation of dynamic elements.
	public Element function create(required String className, required Struct attributes, String textContent = "") {
		return new TagElement(argumentCollection: arguments.attributes)
	}

}