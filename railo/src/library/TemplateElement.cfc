import craft.core.content.Template;

import craft.xml.Element;
import craft.xml.Reader;

component extends="Element" tag="template" {

	public void function construct(required Reader reader) {

		var ref = getRef()

		if (childrenReady()) {
			var section = new Section()
			for (var child in children()) {
				section.addNode(child.product())
			})

			setProduct(new Template(section))
		}

	}

}