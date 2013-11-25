import craft.xml.Element;
import craft.xml.Reader;

component extends="Element" tag="section" {

	public void function construct(required Reader reader) {

		if (childrenReady()) {
			var section = new Section()

			// Now add the child elements to the section.
			for (var nodeElement in sectionElement.children()) {
				section.addNode(nodeElement.product())
			}

			setProduct(section)
		}

	}

	public void function add(required Node element) {
		super.add(arguments.element)
	}

}