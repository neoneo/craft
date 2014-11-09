import craft.util.FileFinder;

component {

	property FileFinder templateFinder;

	public void function init(required String extension) {
		this.templateFinder = new FileFinder(arguments.extension)
	}

	public void function addMapping(required String mapping) {
		this.templateFinder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		this.templateFinder.removeMapping(arguments.mapping)
	}

	public void function clearMappings() {
		this.templateFinder.clear()
	}

	public String function render(required String template, required Struct model) {
		abort showerror="Not implemented";
	}

}