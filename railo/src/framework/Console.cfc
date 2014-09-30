import craft.content.ContentFactory;

import craft.markup.DirectoryBuilder;
import craft.markup.ElementFactory;
import craft.markup.Scope;

import craft.output.CFMLRenderer;
import craft.output.TemplateRenderer;
import craft.output.ViewFactory;

import craft.request.Facade;

/**
 * This component handles all the interactions between the different framework objects and initializes them.
 * An important goal is that changes to settings should have effect without having to reinitialize everything.
 */
component {

	public void function init() {

		this.contentFactory = null
		this.commandFactory = null
		this.elementFactory = null
		this.requestFacade = null
		this.scope = null
		this.templateRenderer = null
		this.viewFactory = null

		/*
			Define dependencies among the framework objects, where keys are dependent objects, and values are arrays of objects being depended upon.
			These dependencies define when an object needs to be recreated. Not all dependencies are present here, because some dependencies can be set.
			In other words, these are the constructor dependencies.
		*/
		this.dependencies = {
			contentFactory: ["viewFactory"],
			commandFactory: ["elementFactory", "scope"],
			elementFactory: ["contentFactory"],
			requestFacade: ["commandFactory"],
			scope: [],
			viewFactory: ["templateRenderer"],
			templateRenderer: []
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
		this.actions.viewFactory = {
			construct: this.viewFactory === null,
			calls: []
		}
		this.actions.contentFactory = {
			construct: this.contentFactory === null,
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
		this.actions.elementFactory.calls.append({deregisterNamespace: [arguments.namespace]})
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

	// ViewFactory ================================================================================

	public void function addViewMapping(required String mapping) {
		this.actions.viewFactory.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeViewMapping(required String mapping) {
		this.actions.viewFactory.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearViewMappings() {
		this.actions.viewFactory.calls.append({clearMappings: []})
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

	private ContentFactory function getContentFactory() {
		var object = this.actions.contentFactory
		if (object.construct) {
			this.contentFactory = createContentFactory()
			object.construct = false
		}

		return this.contentFactory;
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
		var object = this.actions.scope
		if (object.construct) {
			this.scope = createScope()
			object.construct = false
		}

		return this.scope;
	}

	private TemplateRenderer function getTemplateRenderer() {
		var object = this.actions.templateRenderer
		if (object.construct) {
			this.templateRenderer = createTemplateRenderer()
			object.construct = false
		}

		return this.templateRenderer;
	}

	private ViewFactory function getViewFactory() {
		var object = this.actions.viewFactory
		if (object.construct) {
			this.viewFactory = createViewFactory()
			object.construct = false
		}

		return this.viewFactory;
	}

	// FACTORY METHODS ============================================================================

	private ContentFactory function createContentFactory() {
		return new ContentFactory(getViewFactory());
	}

	private CommandFactory function createCommandFactory() {
		return new ContentCommandFactory(getElementFactory(), getScope(), getViewFactory());
	}

	private ElementFactory function createElementFactory() {
		return new ElementFactory(getContentFactory());
	}

	private Facade function createRequestFacade() {
		return new Facade(getCommandFactory());
	}

	private ViewFactory function createViewFactory() {
		return new ViewFactory(getTemplateRenderer());
	}

	private TemplateRenderer function createTemplateRenderer() {
		return new CFMLRenderer();
	}

	private Scope function createScope() {
		return new Scope();
	}

}