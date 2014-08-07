import craft.util.ScopeCollection;

/**
 * Represents an isolated component tree.
 */
component implements="Content" {

	/*
		A section has functional overlap with a composite, but it is not the same thing.
		There is no model or view, and a section can't have a parent. Still, we could think about
		letting section extend composite.
	*/

	variables._components = new ScopeCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public void function traverse(required Visitor visitor) {

		for (var component in components()) {
			component.accept(arguments.visitor)
		}

	}

	public Placeholder[] function placeholders() {
		return placeholdersFromComponents(components())
	}

	public Component[] function components() {
		return variables._components.toArray()
	}

	public void function addComponent(required Component component, Component beforeComponent) {
		variables._components.add(argumentCollection: ArrayToStruct(arguments))
	}

	public void function removeComponent(required Component component) {
		variables._components.remove(arguments.component)
	}

	public void function moveComponent(required Component component, Component beforeComponent) {
		variables._components.move(argumentCollection: ArrayToStruct(arguments))
	}

	private Placeholder[] function placeholdersFromComponents(required Component[] components) {

		var placeholders = []
		arguments.components.each(function (component) {
			if (IsInstanceOf(arguments.component, "Placeholder")) {
				placeholders.append(arguments.component)
			} else if (arguments.component.hasChildren()) {
				placeholders.append(placeholdersFromComponents(arguments.component.children()), true)
			}
		})

		return placeholders
	}

}