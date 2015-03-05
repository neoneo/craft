import craft.content.Layout;
import craft.content.Section;

import craft.markup.Element;
import craft.markup.Scope;

component extends = Element accessors = true tag = layout {

	property String ref required = true;

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var section = new Section()

			this.children.each(function (child) {
				section.addComponent(arguments.child.product)
			})

			this.product = new Layout(section)
		}

	}

}