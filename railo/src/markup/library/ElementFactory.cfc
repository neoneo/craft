import craft.markup.Element;
import craft.markup.Factory;

component implements="Factory" {

	public Element function create(required String class, required Struct attributes, String textContent = "") {
		// None of the elements have an explicit constructor, so we can pass the attributes as the argument collection to set the properties.
		return new "#arguments.class#"(argumentCollection: arguments.attributes);
	}

}