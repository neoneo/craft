import craft.content.Section;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" accessors="true" tag="section" {

	property String placeholder required="true";

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var section = this.getContentFactory().createSection()

			// Now add the child elements to the section.
			this.children.each(function (child) {
				section.addComponent(arguments.child.product)
			})

			this.product = section
		}

	}

	public void function add(required ComponentElement element) {
		super.add(arguments.element)
	}

}