import craft.xml.*;

component extends="Element" {

	public void function construct(required Reader reader) {

		if (!hasChildren() || childrenReady()) {
			var product = new Child(ref: getRef())
			for (var child in children()) {
				product.addChild(child.product())
			}
			setProduct(product)
		}

	}

}