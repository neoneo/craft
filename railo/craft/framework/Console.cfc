import craft.markup.DirectoryBuilder;
import craft.markup.ElementFactory;
import craft.markup.Scope;
import craft.markup.TagRegistry;

import craft.output.CFMLRenderer;
import craft.output.TemplateRenderer;
import craft.output.ViewRepository;

import craft.request.Handler;

/**
 * This component handles all the interactions between the different framework objects and initializes them.
 * An important goal is that changes to settings should have effect without having to reinitialize everything.
 */
component {

	public void function init() {

		this.commandFactory = null
		this.elementFactory = null
		this.handler = null
		this.scope = null
		this.tagRegistry = null
		this.templateRenderer = null
		this.viewRepository = null

		/*
			Define dependencies among the framework objects, where keys are dependent objects, and values are arrays of objects being depended upon.
			These dependencies define when an object needs to be recreated. Not all dependencies are present here, because some dependencies can be set.
			In other words, these are the constructor dependencies.
		*/
		this.dependencies = {
			commandFactory: ["tagRegistry", "scope"],
			elementFactory: [],
			scope: [],
			tagRegistry: ["elementFactory"],
			templateRenderer: [],
			handler: ["commandFactory"],
			viewRepository: ["templateRenderer"]
		}

		initialize()

	}

	private void function initialize() {

		// The actions on commit should be performed in fixed order.
		this.actions = StructNew("linked")

		this.actions.templateRenderer = {
			construct: this.templateRenderer === null,
			calls: []
		}
		this.actions.viewRepository = {
			construct: this.viewRepository === null,
			calls: []
		}
		this.actions.elementFactory = {
			construct: this.elementFactory === null,
			calls: []
		}
		this.actions.tagRegistry = {
			construct: this.tagRegistry === null,
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
		this.actions.handler = {
			construct: this.handler === null,
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
	public Boolean function isUnobtrusiveCommit() {
		return this.actions.every(function (object, data) {
			return !arguments.data.construct;
		});
	}

	public void function reset() {
		this.actions.each(function (object, data) {
			// Flag all objects for construction, except the console.
			arguments.data.construct = arguments.object != "console"
		})
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
	public void function rollback() {
		initialize()
	}

	public void function handleRequest() {
		this.handler.handleRequest()
	}

	// CommandFactory =============================================================================

	public void function setCommandMapping(required String mapping) {
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
		this.actions.elementFactory.calls.append({deregisterNamespace: [arguments.namespace]})
	}
	public void function setElementFactory(required String namespace, required ElementFactory elementFactory) {
		this.actions.tagRegistry.calls.append({setElementFactory: [arguments.namespace, arguments.elementFactory]})
	}

	// Markup documents
	/**
	 * Builds the content in the mapped directory and nakes it available for use by the `ContentCommand`s (via the `ref` attribute).
	 * Do not build content that is directly available via a route; the `ContentCommand` takes care of that. This method is
	 * intended for preloading content such as `Layout`s, `Document`s and included `Element`s.
	 */
	public void function buildContent(required String mapping) {
		this.actions.console.calls.append({build: [ExpandPath(arguments.mapping)]})
	}

	// Endpoint ===================================================================================

	public void function setRootPath(required String rootPath) {
		this.actions.handler.calls.append({setRootPath: [arguments.rootPath]})
	}

	// Handler ==============================================================================

	public void function importRoutes(required String mapping) {
		this.actions.handler.calls.append({importRoutes: [arguments.mapping]})
	}
	public void function purgeRoutes(required String mapping) {
		this.actions.handler.calls.append({purgeRoutes: [arguments.mapping]})
	}

	// TemplateRenderer ===========================================================================

	public void function addTemplateMapping(required String mapping) {
		this.actions.templateRenderer.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeTemplateMapping(required String mapping) {
		this.actions.templateRenderer.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearTemplateMappings() {
		this.actions.templateRenderer.calls.append({clearMappings: []})
	}

	// ViewRepository ================================================================================

	public void function addViewMapping(required String mapping) {
		this.actions.viewRepository.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeViewMapping(required String mapping) {
		this.actions.viewRepository.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearViewMappings() {
		this.actions.viewRepository.calls.append({clearMappings: []})
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
		new DirectoryBuilder(getTagRegistry(), getScope()).build(arguments.path)
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

	private Handler function getHandler() {
		var object = this.actions.handler
		if (object.construct) {
			this.handler = createHandler()
			object.construct = false
		}

		return this.handler;
	}

	private Scope function getScope() {
		var object = this.actions.scope
		if (object.construct) {
			this.scope = createScope()
			object.construct = false
		}

		return this.scope;
	}

	private TagRegistry function getTagRegistry() {
		var object = this.actions.tagRegistry
		if (object.construct) {
			this.tagRegistry = createTagRegistry()
			object.construct = false
		}

		return this.tagRegistry;
	}

	private TemplateRenderer function getTemplateRenderer() {
		var object = this.actions.templateRenderer
		if (object.construct) {
			this.templateRenderer = createTemplateRenderer()
			object.construct = false
		}

		return this.templateRenderer;
	}

	private ViewRepository function getViewRepository() {
		var object = this.actions.viewRepository
		if (object.construct) {
			this.viewRepository = createViewRepository()
			object.construct = false
		}

		return this.viewRepository;
	}

	// FACTORY METHODS ============================================================================

	private CommandFactory function createCommandFactory() {
		return new ContentCommandFactory(getElementFactory(), getScope(), getViewRepository());
	}

	private ElementFactory function createElementFactory() {
		return new DefaultElementFactory();
	}

	private Handler function createHandler() {
		return new Handler(getCommandFactory());
	}

	private TagRegistry function createTagRegistry() {
		return new TagRegistry(getElementFactory());
	}

	private ViewRepository function createViewRepository() {
		return new ViewRepository(getTemplateRenderer());
	}

	private TemplateRenderer function createTemplateRenderer() {
		return new CFMLRenderer();
	}

	private Scope function createScope() {
		return new Scope();
	}

}