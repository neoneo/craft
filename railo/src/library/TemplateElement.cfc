import craft.core.content.Template;

import craft.xml.Element;
import craft.xml.Loader;

component extends="Element" accessors="true" tag="template" {

	property String ref required="true";

	public void function construct(required Repository repository) {

		if (childrenReady()) {
			var section = new Section()
			for (var child in children()) {
				section.addComponent(child.product())
			})

			setProduct(new Template(section))
		}

	}

}