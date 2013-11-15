import craft.core.content.Template;

import craft.core.xml.Element;

component extends="Element" tag="template" {

	public void function construct(required Director director) {

		var ref = getRef()

		if (arguments.director.childrenReady(ref)) {
			var children = arguments.director.children(ref)
			var section = new Section()
			for (var child in children) {
				section.addNode(child.product())
			})

			setProduct(new Template(section))
		}

	}

}