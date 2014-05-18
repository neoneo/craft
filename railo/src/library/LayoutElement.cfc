import craft.core.content.Layout;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" accessors="true" tag="layout" {

	property String ref required="true";

	public void function build(required Scope scope) {

		if (childrenReady()) {
			var section = new Section()
			for (var child in children()) {
				section.addComponent(child.product())
			})

			setProduct(new Layout(section))
		}

	}

}