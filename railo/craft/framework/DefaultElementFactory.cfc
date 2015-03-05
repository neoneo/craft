import craft.markup.ElementFactory;

component implements = ElementFactory {

	public Element function create(required String className, required Struct attributes, String textContent = "") {
		return new "#arguments.className#"(argumentCollection: arguments.attributes);
	}

}