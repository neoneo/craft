import craft.markup.*;

component extends="ElementFactory" {

	// Mock the create method of the factory. Regular mocking doesn't allow for creation of dynamic elements.
	public Element function create(required String namespace, required String tagName, Struct attributes = {}) {
		return new stubs.create.TagElement(this.contentFactory, {ref: arguments.attributes.ref, name: arguments.tagName})
	}

}