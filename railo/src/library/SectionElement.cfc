import craft.xml.Element;
import craft.xml.Reader;

component extends="Element" tag="section" {

	public void function construct(required Reader reader) {

		if (childrenReady()) {
			var section = new Section()

			// Now add the child elements to the section.
			for (var componentElement in sectionElement.children()) {
				section.addComponent(componentElement.product())
			}

			setProduct(section)
		}

	}

	public void function add(required ComponentElement element) {
		super.add(arguments.element)
	}

}