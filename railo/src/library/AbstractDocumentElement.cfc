import craft.core.content.Document;
import craft.core.content.TemplateContent;

import craft.xml.Element;
import craft.xml.Loader;

/**
 * @abstract
 */
component extends="Element" {

	public void function construct(required Repository repository) {

		var templateRef = templateRef()
		if (arguments.repository.hasElement(templateRef)) {
			var template = arguments.repository.element(templateRef)

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
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

	private Document function createDocument(required TemplateContent templateContent) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

}