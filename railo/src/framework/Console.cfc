import craft.markup.DirectoryBuilder;
import craft.markup.ElementFactory;
import craft.markup.Scope;

import craft.output.CFMLRenderer;
import craft.output.TemplateFinder;
import craft.output.TemplateRenderer;
import craft.output.ViewFinder;

import craft.request.Facade;

/**
 * This component handles all the interactions between the different framework objects and initializes them.
 * An important goal is that changes to settings should have effect without having to reinitialize everything.
 */
component {

	public void function init() {

		this.commandFactory = null
		this.elementFactory = null
		this.requestFacade = null
		this.scope = null
		this.templateFinder = null
		this.viewFinder = null

		// Define dependencies among the framework objects.
		this.dependencies = {
			commandFactory: ["elementFactory", "scope", "viewFinder"],
			elementFactory: [],
			requestFacade: ["commandFactory"],
			scope: [],
			templateFinder: ["extension"],
			viewFinder: ["templateFinder", "templateRenderer"]
		}

		initialize()

	}

	private void function initialize() {

		this.actions = StructNew("linked")

		this.actions.templateFinder = {
			construct: this.templateFinder === null,
			calls: []
		}
		this.actions.viewFinder = {
			construct: this.viewFinder === null,
			calls: []
		}
		this.actions.elementFactory = {
			construct: this.elementFactory === null,
			calls: []
		}
		this.actions.scope = {
			construct: this.scope === null,
			calls: []
		}
		this.actions.commandFactory = {
			construct: this.commandFactory === null,
			calls: []
		}
		this.actions.requestFacade = {
			construct: this.requestFacade === null,
			calls: []
		}
		this.actions.console = {
			construct: false,
			calls: []
		}

	}

	/**
	 * Returns whether any of the framework objects have to be constructed (again) in order for the changes to take effect.
	 */
	public Boolean function canCommitWithoutConstruction() {
		return this.actions.every(function (object, data) {
			return !arguments.data.construct;
		});
	}

	/**
	 * Carries out the changes.
	 */
	public void function commit() {

		// First construct any framework objects.
		var instances = this.actions.map(function (object) {
			// Call the corresponding factory method. It creates nothing if the object is not flagged.
			return Invoke(this, "get" & arguments.object);
		})

		// Perform method calls on the framework objects.
		instances.each(function (object, instance) {
			var calls = this.actions[arguments.object].calls
			// Loop through the calls, and remove every successful one.
			while (!calls.isEmpty()) {
				// Calls is an array of structs, where keys are method names, and values are argument arrays.
				for (var method in calls[1]) {
					Invoke(arguments.instance, method, calls[1][method])
				}
				calls.deleteAt(1)
			}
		})

	}

	/**
	 * Reverts any uncommitted changes to the settings.
	 */
	public void function revert() {
		initialize()
	}

	public void function handleRequest() {
		this.requestFacade.handleRequest()
	}

	// CommandFactory =============================================================================

	public void function setContentMapping(required String mapping) {
		this.actions.commandFactory.calls.append({setPath: [ExpandPath(arguments.mapping)]})
	}

	// ElementFactory =============================================================================

	public void function registerElements(required String mapping) {
		this.actions.elementFactory.calls.append({register: [arguments.mapping]})
	}
	public void function deregisterElements(required String mapping) {
		this.actions.elementFactory.calls.append({deregister: [arguments.mapping]})
	}
	public void function deregisterNamespace(required String namespace) {
		this.actions.elementFactory.calls.append({deregisterNamespace: [arguments.mapping]})
	}

	// Markup documents
	/**
	 * Builds the content in the mapped directory and nakes it available for use by the `ContentCommand`s (via the `ref` attribute).
	 * Do not build content that is directly available via a route; the `ContentCommand` takes care of that. This method is
	 * intended for the loading of `Layout`s and `Document`s or included `Element`s.
	 */
	public void function buildContent(required String mapping) {
		this.actions.console.calls.append({build: [ExpandPath(arguments.mapping)]})
	}

	// EndPoint ===================================================================================

	public void function setRootPath(required String rootPath) {
		this.actions.requestFacade.calls.append({setRootPath: [arguments.rootPath]})
	}

	// RoutesParser ===============================================================================

	public void function importRoutes(required String mapping) {
		this.actions.requestFacade.calls.append({importRoutes: [arguments.mapping]})
	}

	public void function purgeRoutes(required String mapping) {
		this.actions.requestFacade.calls.append({purgeRoutes: [arguments.mapping]})
	}

	// TemplateFinder =============================================================================

	public void function setTemplateExtension(required String extension) {
		flagDependencies("extension")
		this.actions.templateFinder.extension = arguments.extension
	}
	public void function addTemplateMapping(required String mapping) {
		this.actions.templateFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeTemplateMapping(required String mapping) {
		this.actions.templateFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearTemplateMappings() {
		this.actions.templateFinder.calls.append({clear: []})
	}

	// ViewFinder =================================================================================

	public void function setTemplateRenderer(required TemplateRenderer templateRenderer) {
		flagDependencies("templateRenderer")
		this.actions.viewFinder.templateRenderer = arguments.templateRenderer
	}
	public void function addViewMapping(required String mapping) {
		this.actions.viewFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeViewMapping(required String mapping) {
		this.actions.viewFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearViewMappings() {
		this.actions.viewFinder.calls.append({clear: []})
	}

	// Factory / wiring methods

	/**
	 * Flags all objects that depend on the object for construction.
	 */
	private void function flagDependencies(required String object) {

		var object = arguments.object
		this.dependencies.each(function (client, dependencies) {
			if (arguments.dependencies.find(object) > 0) {
				this.actions[arguments.client].construct = true
				flagDependencies(arguments.client)
			}
		})

	}

	private void function build(required String path) {
		new DirectoryBuilder(getElementFactory(), getScope()).build(arguments.path)
	}

	private CommandFactory function getCommandFactory() {
		var object = this.actions.commandFactory
		if (object.construct) {
			this.commandFactory = createCommandFactory()
			object.construct = false
		}

		return this.commandFactory;
	}

	private Console function getConsole() {
		return this;
	}

	private ElementFactory function getElementFactory() {
		var object = this.actions.elementFactory
		if (object.construct) {
			this.elementFactory = createElementFactory()
			object.construct = false
		}

		return this.elementFactory;
	}

	private Facade function getRequestFacade() {
		var object = this.actions.requestFacade
		if (object.construct) {
			this.requestFacade = createRequestFacade()
			object.construct = false
		}

		return this.requestFacade;
	}

	private Scope function getScope() {
		var object = this.actions.Scope
		if (object.construct) {
			this.scope = createScope()
			object.construct = false
		}

		return this.scope;
	}

	private TemplateFinder function getTemplateFinder() {
		var object = this.actions.templateFinder
		if (object.construct) {
			this.extension = object.extension ?: this.extension ?: "cfm"
			this.templateFinder = createTemplateFinder()
			object.construct = false
		}

		return this.templateFinder;
	}

	private ViewFinder function getViewFinder() {
		var object = this.actions.viewFinder
		if (object.construct) {
			this.templateRenderer = object.templateRenderer ?: this.templateRenderer ?: new CFMLRenderer()
			this.viewFinder = createViewFinder()
			object.construct = false
		}

		return this.viewFinder;
	}

	// FACTORY METHODS ============================================================================

	private CommandFactory function createCommandFactory() {
		return new ContentCommandFactory(getElementFactory(), getScope(), getViewFinder());
	}

	private ElementFactory function createElementFactory() {
		return new ElementFactory();
	}

	private Facade function createRequestFacade() {
		return new Facade(getCommandFactory());
	}

	private TemplateFinder function createTemplateFinder() {
		return new TemplateFinder(this.extension);
	}

	private ViewFinder function createViewFinder() {
		return new ViewFinder(getTemplateFinder(), this.templateRenderer);
	}

	private Scope function createScope() {
		return new Scope();
	}

}