import craft.util.Collection;
import craft.util.ScopeCollection;

/**
 * Represents an isolated component tree.
 */
component implements = Content accessors = true {

	property Array components setter = false; // Component[]
	property Boolean hasComponents setter = false;
	property Array placeholders setter = false; // Placeholder[]

	/*
		A section has functional overlap with a composite, but it is not the same thing.
		There is no model or view, and a section can't have a parent. Still, we could think about
		letting section extend composite.
	*/

	this.componentCollection = this.createCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public Boolean function getHasComponents() {
		return !this.componentCollection.isEmpty();
	}

	public Component[] function getComponents() {
		return this.componentCollection.toArray();
	}

	public Placeholder[] function getPlaceholders() {
		return placeholdersFromComponents(this.getComponents());
	}

	private Placeholder[] function placeholdersFromComponents(required Component[] components) {

		var placeholders = []
		ArrayEach(arguments.components, function (component) {
			if (IsInstanceOf(arguments.component, "Placeholder")) {
				placeholders.append(arguments.component)
			} else if (arguments.component.hasChildren) {
				placeholders.append(placeholdersFromComponents(arguments.component.children), true)
			}
		})

		return placeholders;
	}

	public Boolean function addComponent(required Component component, Component beforeComponent) {
		return this.componentCollection.add(arguments.component, arguments.beforeComponent ?: null);
	}

	public Boolean function removeComponent(required Component component) {
		return this.componentCollection.remove(arguments.component);
	}

	public Boolean function moveComponent(required Component component, Component beforeComponent) {
		return this.componentCollection.move(arguments.component, arguments.beforeComponent ?: null);
	}

	public void function traverse(required Visitor visitor) {
		for (var component in this.getComponents()) {
			component.accept(arguments.visitor)
		}
	}

	private Collection function createCollection() {
		return new ScopeCollection();
	}

}