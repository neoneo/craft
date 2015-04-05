import craft.content.Section;

import craft.markup.Element;
import craft.markup.Scope;

component extends = Element accessors = true tag = section {

	property String placeholder required = true;

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var section = new Section()

			// Now add the child elements to the section.
			for (var child in this.children) {
				section.addComponent(child.product)
			})

			this.product = section
		}

	}

	public void function add(required ComponentElement element) {
		super.add(arguments.element)
	}

}