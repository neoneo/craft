import craft.core.content.Section;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" accessors="true" tag="section" {

	property String placeholder required="true";

	public void function construct(required Scope scope) {

		if (childrenReady()) {
			var section = new Section()

			// Now add the child elements to the section.
			children().each(function (child) {
				section.addComponent(arguments.child.product())
			})

			setProduct(section)
		}

	}

	public void function add(required ComponentElement element) {
		super.add(arguments.element)
	}

}