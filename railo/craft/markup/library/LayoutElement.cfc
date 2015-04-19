import craft.content.Layout;
import craft.content.Section;

import craft.markup.Element;
import craft.markup.Scope;

component extends = Element accessors = true alias = layout {

	property String ref required = true;

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var section = new Section()

			for (var child in this.children) {
				section.addComponent(child.product)
			}

			this.product = new Layout(section)
		}

	}

}