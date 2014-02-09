import craft.xml.Element;
import craft.xml.Loader;

component extends="Element" accessors="true" tag="section" {

	property String ref required="true";

	public void function construct(required Loader loader) {

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