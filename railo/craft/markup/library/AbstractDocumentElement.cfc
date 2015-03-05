import craft.content.Document;
import craft.content.LayoutContent;

import craft.markup.Element;
import craft.markup.Scope;

component extends = Element abstract = true {

	property String layoutRef setter = false;

	public void function construct(required Scope scope) {

		var layoutRef = this.getLayoutRef()
		if (arguments.scope.has(layoutRef)) {
			var layout = arguments.scope.get(layoutRef)

			if (layout.getReady() && this.getChildrenReady()) {
				var document = this.createDocument(layout.product)

				// The child elements are all section elements. Each section element may contain multiple child elements.
				this.children.each(function (child) {
					// Add the section under the placeholder attribute.
					document.fillPlaceholder(arguments.child.placeholder, arguments.child.product)
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