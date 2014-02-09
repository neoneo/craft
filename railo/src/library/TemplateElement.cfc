import craft.core.content.Template;

import craft.xml.Element;
import craft.xml.Loader;

component extends="Element" tag="template" {

	public void function construct(required Loader loader) {

		var ref = getRef()

		if (childrenReady()) {
			var section = new Section()
			for (var child in children()) {
				section.addComponent(child.product())
			})

			setProduct(new Template(section))
		}

	}

}