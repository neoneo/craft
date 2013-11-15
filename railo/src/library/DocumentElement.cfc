import craft.core.content.Document;
import craft.core.content.TemplateContent;

import craft.core.xml.Element;

/**
 * @abstract
 */
component extends="Element" {

	public Boolean function construct(required Director director) {

		var templateRef = templateRef()
		if (arguments.director.hasElement(templateRef)) {
			var template = arguments.director.element(templateRef)

			var ref = getRef()
			if (template.ready() && arguments.director.childrenReady(ref)) {
				var product = createDocument(template.product())

				// The child elements must all be sections. Each section element may contain multiple child elements.
				for (var element in arguments.director.children(ref)) {
					var elementRef = element.getRef()

					var section = new Section()

					// Now add the child elements to the section.
					for (var child in arguments.director.children(elementRef)) {
						section.addNode(child.product())
					}

					// Add the section under the ref of the section element (which refers to a placeholder with the same ref).
					product.addSection(section, elementRef)
				}

				setProduct(product)
			}
		}

	}

	private String function templateRef() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	private Document function createDocument(required TemplateContent templateContent) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}