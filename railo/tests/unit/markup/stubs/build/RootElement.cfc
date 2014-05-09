import craft.markup.*;

component extends="Element" {

	public void function construct(required Reader reader) {

		if (childrenReady()) {
			var product = new Root()
			for (var child in children()) {
				product.addChild(child.product())
			}
			setProduct(product)
		}
	}

}