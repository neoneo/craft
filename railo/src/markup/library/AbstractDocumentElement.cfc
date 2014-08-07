import craft.content.Document;
import craft.content.LayoutContent;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" abstract="true" {

	public void function construct(required Scope scope) {

		var layoutRef = layoutRef()
		if (arguments.scope.has(layoutRef)) {
			var layout = arguments.scope.get(layoutRef)

			if (layout.ready() && childrenReady()) {
				var document = createDocument(layout.product())

				// The child elements are all section elements. Each section element may contain multiple child elements.
				children().each(function (child) {
					// Add the section under the placeholder attribute.
					document.addSection(arguments.child.product(), arguments.child.getPlaceholder())
				})

				setProduct(document)
			}
		}

	}

	public void function add(required SectionElement element) {
		super.add(arguments.element)
	}

	private String function layoutRef() {
		abort showerror="Not implemented";
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		abort showerror="Not implemented";
	}

}