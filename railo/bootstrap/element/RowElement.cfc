import craft.markup.library.CompositeElement;

component extends="CompositeElement" tag="row" {

	private Composite function create() {
		return new bootstrap.component.Row();
	}

}