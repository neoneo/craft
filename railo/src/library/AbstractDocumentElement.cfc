import craft.core.content.Document;
import craft.core.content.LayoutContent;

import craft.markup.Element;
import craft.markup.Loader;

/**
 * @abstract
 */
component extends="Element" {

	public void function construct(required Repository repository) {

		var layoutRef = layoutRef()
		if (arguments.repository.hasElement(layoutRef)) {
			var layout = arguments.repository.element(layoutRef)

			if (layout.ready() && childrenReady()) {
				var document = createDocument(layout.product())

				// The child elements are all section elements. Each section element may contain multiple child elements.
				for (var sectionElement in children()) {
					// Add the section under the ref of the section element (which refers to a placeholder with the same ref).
					document.addSection(sectionElement.product(), sectionElement.getRef())
				}

				setProduct(document)
			}
		}

	}

	public void function add(required Section element) {
		super.add(arguments.element)
	}

	private String function layoutRef() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

}