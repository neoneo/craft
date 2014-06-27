import craft.core.content.Layout;
import craft.core.content.Section;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" accessors="true" tag="layout" {

	property String ref required="true";

	public void function construct(required Scope scope) {

		if (childrenReady()) {
			var section = new Section()

			children().each(function (child) {
				section.addComponent(arguments.child.product())
			})

			setProduct(new Layout(section))
		}

	}

}