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

		variables._commandFactory = null
		variables._elementFactory = null
		variables._requestFacade = null
		variables._scope = null
		variables._templateFinder = null
		variables._viewFinder = null

		// Define dependencies among the framework objects.
		variables._dependencies = {
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

		var actions = variables._actions = StructNew("linked")

		actions.templateFinder = {
			construct: variables._templateFinder === null,
			calls: []
		}
		actions.viewFinder = {
			construct: variables._viewFinder === null,
			calls: []
		}
		actions.elementFactory = {
			construct: variables._elementFactory === null,
			calls: []
		}
		actions.scope = {
			construct: variables._scope === null,
			calls: []
		}
		actions.commandFactory = {
			construct: variables._commandFactory === null,
			calls: []
		}
		actions.requestFacade = {
			construct: variables._requestFacade === null,
			calls: []
		}
		actions.console = {
			construct: false,
			calls: []
		}

	}

	/**
	 * Returns whether any of the framework objects have to be constructed (again) in order for the changes to take effect.
	 */
	public Boolean function canCommitWithoutConstruction() {
		return variables._actions.every(function (object, data) {
			return !arguments.data.construct;
		});
	}

	/**
	 * Carries out the changes.
	 */
	public void function commit() {

		// First construct any framework objects.
		// var instances = variables._actions.map(function (object) {
			// Call the corresponding factory method. It creates nothing if the object is not flagged.
			// return Invoke(this, arguments.object);
		// })

		// Hopefully temporary workaround for bug where .map on a linked struct returns a regular struct.
		var instances = StructNew("linked")
		variables._actions.each(function (object) {
			instances[arguments.object] = Invoke(this, arguments.object)
		})

		// Perform method calls on the framework objects.
		instances.each(function (object, instance) {
			var calls = variables._actions[arguments.object].calls
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
		variables._requestFacade.handleRequest()
	}

	// CommandFactory =============================================================================

	public void function setContentMapping(required String mapping) {
		variables._actions.commandFactory.calls.append({setPath: [ExpandPath(arguments.mapping)]})
	}

	// ElementFactory =============================================================================

	public void function registerElements(required String mapping) {
		variables._actions.elementFactory.calls.append({register: [arguments.mapping]})
	}
	public void function deregisterElements(required String mapping) {
		variables._actions.elementFactory.calls.append({deregister: [arguments.mapping]})
	}
	public void function deregisterNamespace(required String namespace) {
		variables._actions.elementFactory.calls.append({deregisterNamespace: [arguments.mapping]})
	}

	// Markup documents
	/**
	 * Builds the content in the mapped directory and nakes it available for use by the `ContentCommand`s (via the `ref` attribute).
	 * Do not build content that is directly available via a route; the `ContentCommand` takes care of that. This method is
	 * intended for the loading of `Layout`s and `Document`s or included `Element`s.
	 */
	public void function buildContent(required String mapping) {
		variables._actions.console.calls.append({build: [ExpandPath(arguments.mapping)]})
	}

	// EndPoint ===================================================================================

	public void function setRootPath(required String rootPath) {
		variables._actions.requestFacade.calls.append({setRootPath: [arguments.rootPath]})
	}

	// RoutesParser ===============================================================================

	public void function importRoutes(required String mapping) {
		variables._actions.requestFacade.calls.append({importRoutes: [arguments.mapping]})
	}

	public void function purgeRoutes(required String mapping) {
		variables._actions.requestFacade.calls.append({purgeRoutes: [arguments.mapping]})
	}

	// TemplateFinder =============================================================================

	public void function setTemplateExtension(required String extension) {
		flagDependencies("extension")
		variables._actions.templateFinder.extension = arguments.extension
	}
	public void function addTemplateMapping(required String mapping) {
		variables._actions.templateFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeTemplateMapping(required String mapping) {
		variables._actions.templateFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearTemplateMappings() {
		variables._actions.templateFinder.calls.append({clear: []})
	}

	// ViewFinder =================================================================================

	public void function setTemplateRenderer(required TemplateRenderer templateRenderer) {
		flagDependencies("templateRenderer")
		variables._actions.viewFinder.templateRenderer = arguments.templateRenderer
	}
	public void function addViewMapping(required String mapping) {
		variables._actions.viewFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeViewMapping(required String mapping) {
		variables._actions.viewFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearViewMappings() {
		variables._actions.viewFinder.calls.append({clear: []})
	}

	// Factory / wiring methods

	/**
	 * Flags all objects that depend on the object for construction.
	 */
	private void function flagDependencies(required String object) {

		var object = arguments.object
		variables._dependencies.each(function (client, dependencies) {
			if (arguments.dependencies.find(object) > 0) {
				variables._actions[arguments.client].construct = true
				flagDependencies(arguments.client)
			}
		})

	}

	private void function build(required String path) {
		new DirectoryBuilder(elementFactory(), scope()).build(arguments.path)
	}

	private CommandFactory function commandFactory() {
		var object = variables._actions.commandFactory
		if (object.construct) {
			variables._commandFactory = createCommandFactory()
			object.construct = false
		}

		return variables._commandFactory;
	}

	private Console function console() {
		return this;
	}

	private ElementFactory function elementFactory() {
		var object = variables._actions.elementFactory
		if (object.construct) {
			variables._elementFactory = createElementFactory()
			object.construct = false
		}

		return variables._elementFactory;
	}

	private Facade function requestFacade() {
		var object = variables._actions.requestFacade
		if (object.construct) {
			variables._requestFacade = createRequestFacade()
			object.construct = false
		}

		return variables._requestFacade;
	}

	private Scope function scope() {
		var object = variables._actions.Scope
		if (object.construct) {
			variables._scope = createScope()
			object.construct = false
		}

		return variables._scope;
	}

	private TemplateFinder function templateFinder() {
		var object = variables._actions.templateFinder
		if (object.construct) {
			variables._extension = object.extension ?: variables._extension ?: "cfm"
			variables._templateFinder = createTemplateFinder()
			object.construct = false
		}

		return variables._templateFinder;
	}

	private ViewFinder function viewFinder() {
		var object = variables._actions.viewFinder
		if (object.construct) {
			variables._templateRenderer = object.templateRenderer ?: variables._templateRenderer ?: new CFMLRenderer()
			variables._viewFinder = createViewFinder()
			object.construct = false
		}

		return variables._viewFinder;
	}

	// FACTORY METHODS ============================================================================

	private CommandFactory function createCommandFactory() {
		return new ContentCommandFactory(elementFactory(), scope(), viewFinder());
	}

	private ElementFactory function createElementFactory() {
		return new ElementFactory();
	}

	private Facade function createRequestFacade() {
		return new Facade(commandFactory());
	}

	private TemplateFinder function createTemplateFinder() {
		return new TemplateFinder(variables._extension);
	}

	private ViewFinder function createViewFinder() {
		return new ViewFinder(templateFinder(), variables._templateRenderer);
	}

	private Scope function createScope() {
		return new Scope();
	}

}