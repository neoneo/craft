import craft.core.content.Document;
import craft.core.content.TemplateContent;

import craft.core.xml.Element;
import craft.core.xml.Reader;

/**
 * @abstract
 */
component extends="Element" {

	public void function construct(required Reader reader) {

		var templateRef = templateRef()
		if (arguments.reader.hasElement(templateRef)) {
			var template = arguments.reader.element(templateRef)

			if (template.ready() && childrenReady()) {
				var document = createDocument(template.product())

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

	private String function templateRef() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private Document function createDocument(required TemplateContent templateContent) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}