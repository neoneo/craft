import craft.markup.*;

component extends="Element" {

	public void function build(required Scope scope) {

		if (!hasChildren() || childrenReady()) {
			var product = new Child(ref: getRef())
			for (var child in children()) {
				product.addChild(child.product())
			}
			setProduct(product)
		}

	}

}