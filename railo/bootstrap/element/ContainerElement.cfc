import craft.markup.library.CompositeElement;

component extends="CompositeElement" accessors = true tag="container" {

	property Boolean fluid default="true";

	private Composite function create() {
		return this.contentFactory.create("bootstrap.component.Container", this.fluid);
	}

}