import craft.content.Document;
import craft.content.LayoutContent;

import craft.markup.Element;
import craft.markup.Scope;

/**
 * @abstract
 */
component extends = Element {

	property String layoutRef setter = false;

	public void function construct(required Scope scope) {

		var layoutRef = this.getLayoutRef()
		if (arguments.scope.has(layoutRef)) {
			var layout = arguments.scope.get(layoutRef)

			if (layout.getReady() && this.getChildrenReady()) {
				var document = this.createDocument(layout.product)

				// The child elements are all section elements. Each section element may contain multiple child elements.
				for (var child in this.children) {
					// Add the section under the placeholder attribute.
					document.fillPlaceholder(child.placeholder, child.product)
				})

				this.product = document
			}
		}

	}

	public void function add(required SectionElement element) {
		super.add(arguments.element)
	}

	private String function getLayoutRef() {
		abort showerror="Not implemented";
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		abort showerror="Not implemented";
	}

}