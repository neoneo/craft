import craft.util.ScopeCollection;

/**
 * Represents an isolated component tree.
 */
component implements="Content" accessors="true" {

	property Array components setter="false"; // Component[]
	property Array placeholders setter="false"; // Placeholder[]

	/*
		A section has functional overlap with a composite, but it is not the same thing.
		There is no model or view, and a section can't have a parent. Still, we could think about
		letting section extend composite.
	*/

	this.componentCollection = new ScopeCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public void function traverse(required Visitor visitor) {

		for (var component in this.getComponents()) {
			component.accept(arguments.visitor)
		}

	}

	public Component[] function getComponents() {
		return this.componentCollection.toArray();
	}

	public Placeholder[] function getPlaceholders() {
		return placeholdersFromComponents(this.getComponents());
	}

	public void function addComponent(required Component component, Component beforeComponent) {
		this.componentCollection.add(argumentCollection: ArrayToStruct(arguments))
	}

	public void function removeComponent(required Component component) {
		this.componentCollection.remove(arguments.component)
	}

	public void function moveComponent(required Component component, Component beforeComponent) {
		this.componentCollection.move(argumentCollection: ArrayToStruct(arguments))
	}

	private Placeholder[] function placeholdersFromComponents(required Component[] components) {

		var placeholders = []
		arguments.components.each(function (component) {
			if (IsInstanceOf(arguments.component, "Placeholder")) {
				placeholders.append(arguments.component)
			} else if (arguments.component.hasChildren) {
				placeholders.append(placeholdersFromComponents(arguments.component.children), true)
			}
		})

		return placeholders;
	}

}