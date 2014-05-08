import craft.core.content.Layout;

import craft.markup.Element;
import craft.markup.Loader;

component extends="Element" accessors="true" tag="layout" {

	property String ref required="true";

	public void function construct(required Repository repository) {

		if (childrenReady()) {
			var section = new Section()
			for (var child in children()) {
				section.addComponent(child.product())
			})

			setProduct(new Layout(section))
		}

	}

}