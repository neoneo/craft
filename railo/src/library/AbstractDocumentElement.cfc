import craft.core.content.Document;
import craft.core.content.LayoutContent;

import craft.markup.Element;
import craft.markup.Scope;

/**
 * @abstract
 */
component extends="Element" {

	public void function build(required Scope scope) {

		var layoutRef = layoutRef()
		if (arguments.scope.has(layoutRef)) {
			var layout = arguments.scope.get(layoutRef)

			if (layout.ready() && childrenReady()) {
				var document = createDocument(layout.product())

				// The child elements are all section elements. Each section element may contain multiple child elements.
				children().each(function (child) {
					// Add the section under the ref of the section element (which refers to a placeholder with the same ref).
					document.addSection(arguments.child.product(), arguments.child.getRef())
				})

				setProduct(document)
			}
		}

	}

	public void function add(required Section element) {
		super.add(arguments.element)
	}

	private String function layoutRef() {
		abort showerror="Not implemented";
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		abort showerror="Not implemented";
	}

}