import craft.content.ContentFactory;

import craft.markup.DirectoryBuilder;
import craft.markup.ElementFactory;
import craft.markup.Scope;

import craft.output.CFMLRenderer;
import craft.output.TemplateFinder;
import craft.output.TemplateRenderer;
import craft.output.ViewFactory;
import craft.output.ViewFinder;
import craft.output.ViewRenderer;

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
		this.extension = null
		this.requestFacade = null
		this.scope = null
		this.templateFinder = null
		this.templateRenderer = null
		this.viewFactory = null
		this.viewFinder = null
		this.viewRenderer = null

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
			templateFinder: ["extension"],
			viewFactory: ["viewFinder", "viewRenderer"],
			viewFinder: [],
			viewRenderer: ["templateFinder"]
		}

		initialize()

	}

	private void function initialize() {

		// The actions on commit should be performed in fixed order.
		this.actions = StructNew("linked")

		this.actions.templateFinder = {
			construct: this.templateFinder === null,
			calls: []
		}
		this.actions.viewFinder = {
			construct: this.viewFinder === null,
			calls: []
		}
		this.actions.viewRenderer = {
			construct: this.viewRenderer === null,
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
	// public void function addTemplateMapping(required String mapping) {
	// 	this.actions.templateFinder.calls.append({addMapping: [arguments.mapping]})
	// }
	// public void function removeTemplateMapping(required String mapping) {
	// 	this.actions.templateFinder.calls.append({removeMapping: [arguments.mapping]})
	// }
	// public void function clearTemplateMappings() {
	// 	this.actions.templateFinder.calls.append({clear: []})
	// }

	public void function setTemplateRenderer(required TemplateRenderer templateRenderer) {
		flagDependencies("templateRenderer")
		this.actions.viewRenderer.calls.append({setTemplateRenderer: [arguments.templateRenderer]})
	}

	// ViewFinder =================================================================================

	public void function addViewMapping(required String mapping) {
		this.actions.viewFinder.calls.append({addMapping: [arguments.mapping]})
		this.actions.templateFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeViewMapping(required String mapping) {
		this.actions.viewFinder.calls.append({removeMapping: [arguments.mapping]})
		this.actions.templateFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearViewMappings() {
		this.actions.viewFinder.calls.append({clear: []})
		this.actions.templateFinder.calls.append({clear: []})
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

	private ViewFactory function getViewFactory() {
		var object = this.actions.viewFactory
		if (object.construct) {
			this.viewFactory = createViewFactory()
			object.construct = false
		}

		return this.viewFactory;
	}

	private ViewFinder function getViewFinder() {
		var object = this.actions.viewFinder
		if (object.construct) {
			this.viewFinder = createViewFinder()
			object.construct = false
		}

		return this.viewFinder;
	}

	private ViewRenderer function getViewRenderer() {
		var object = this.actions.viewRenderer
		if (object.construct) {
			this.viewRenderer = createViewRenderer()
			object.construct = false
		}

		return this.viewFinder;
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

	private TemplateFinder function createTemplateFinder() {
		return new TemplateFinder(this.extension);
	}

	private ViewFactory function createViewFactory() {
		return new ViewFactory(getViewFinder());
	}

	private ViewFinder function createViewFinder() {
		return new ViewFinder();
	}

	private ViewRenderer function createViewRenderer() {
		return new ViewRenderer(getTemplateFinder());
	}

	private Scope function createScope() {
		return new Scope();
	}

}