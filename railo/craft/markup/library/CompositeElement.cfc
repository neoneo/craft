import craft.content.Composite;

import craft.markup.Element;
import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 *
 * @abstract
 */
component extends = ComponentElement {

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var composite = createComponent()

			for (var child in this.children) {
				composite.addChild(child.product)
			})

			this.product = composite
		}

	}

	private Composite function createComponent() {
		abort showerror="Not implemented";
	}

}