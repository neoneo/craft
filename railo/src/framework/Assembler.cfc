import craft.markup.ElementFactory;

import craft.output.CFMLRenderer;
import craft.output.TemplateFinder;
import craft.output.TemplateRenderer;
import craft.output.ViewFinder;

import craft.request.CommandFactory;
import craft.request.EndPoint;
import craft.request.PathSegment;
import craft.request.PathSegmentFactory;
import craft.request.RoutesParser;

/**
 * This component handles all the interactions between the different framework objects and initializes them.
 * An important goal is that changes to settings should have effect without having to reinitialize everything.
 */
component {

	public void function init() {

		initialize()
		// All objects have to be constructed.
		variables._objects.keyArray().each(function (object, data) {
			arguments.data.construct = true
		})

		// Define dependencies among the framework objects.
		variables._dependencies = {
			CommandFactory: ["ElementFactory", "ViewFinder"],
			EndPoint: [],
			ElementFactory: [],
			PathSegmentFactory: [],
			RoutesParser: ["PathSegmentFactory", "CommandFactory"],
			TemplateFinder: [],
			ViewFinder: ["TemplateFinder"]
		}

	}

	private void function initialize() {

		variables._objects = {
			CommandFactory: {
				construct: false,
				calls: []
			},
			EndPoint: {
				construct: false,
				calls: []
			},
			ElementFactory: {
				construct: false,
				calls: []
			},
			PathSegmentFactory: {
				construct: false,
				calls: []
			},
			RoutesParser: {
				construct: false,
				calls: []
			},
			TemplateFinder: {
				construct: false,
				calls: []
			},
			ViewFinder: {
				construct: false,
				calls: []
			}
		}

	}

	/**
	 * Returns whether any of the framework objects have to be constructed (again) in order for the changes to take effect.
	 */
	public Boolean function canCommitWithoutConstruction() {
		return variables._objects.every(function (object, data) {
			return !arguments.data.construct
		})
	}

	/**
	 * Carries out the modifications.
	 */
	public void function commit() {

		// First construct any framework objects.
		var instances = variables._objects.map(function (object) {
			// Call the corresponding factory method. It creates nothing if the object is not flagged.
			return Invoke(this, arguments.object)
		})

		// Perform method calls on the framework objects.
		instances.each(function (object, instance) {
			var instance = arguments.instance
			var calls = variables._objects[arguments.object].calls
			// Loop through the calls, and remove every successful one.
			while (!calls.isEmpty()) {
				// Calls is an array of structs, where keys are method names, and values are argument arrays.
				calls[1].each(function (method, values) {
					Invoke(instance, arguments.method, arguments.values)
				})
				calls.deleteAt(1)
			}
		})

	}

	/**
	 * Reverts any uncommitted modifications to the settings.
	 */
	public void function revert() {
		initialize()
	}


	// CommandFactory =============================================================================

	public void function setCommandMapping(required String mapping) {
		variables._objects.CommandFactory.calls.append({setPath: [ExpandPath(arguments.mapping)]})
	}

	// ElementFactory =============================================================================

	public void function registerElements(required String mapping) {
		variables._objects.ElementFactory.calls.append({register: [arguments.mapping]})
	}
	public void function deregisterElements(required String mapping) {
		variables._objects.ElementFactory.calls.append({deregister: [arguments.mapping]})
	}
	public void function deregisterNamespace(required String namespace) {
		variables._objects.ElementFactory.calls.append({deregisterNamespace: [arguments.mapping]})
	}

	// EndPoint ===================================================================================

	public void function setRootPath(required String rootPath) {
		variables._objects.EndPoint.calls.append({setRootPath: [arguments.rootPath]})
	}

	// RoutesParser ===============================================================================

	public void function importRoutes(required String mapping) {
		variables._objects.RoutesParser.calls.append({import: [ExpandPath(arguments.mapping)]})
	}

	public void function purgeRoutes(required String mapping) {
		variables._objects.RoutesParser.calls.append({purge: [ExpandPath(arguments.mapping)]})
	}

	// TemplateFinder =============================================================================

	public void function setTemplateExtension(required String extension) {
		flagConstruction("TemplateFinder")
		variables._objects.TemplateFinder.extension = arguments.extension
	}
	public void function addTemplateMapping(required String mapping) {
		variables._objects.TemplateFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeTemplateMapping(required String mapping) {
		variables._objects.TemplateFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearTemplateMappings() {
		variables._objects.TemplateFinder.calls.append({clear: []})
	}

	// ViewFinder =================================================================================

	public void function setTemplateRenderer(required TemplateRenderer templateRenderer) {
		flagConstruction("ViewFinder")
		variables._objects.ViewFinder.templateRenderer = arguments.templateRenderer
	}
	public void function addViewMapping(required String mapping) {
		variables._objects.ViewFinder.calls.append({addMapping: [arguments.mapping]})
	}
	public void function removeViewMapping(required String mapping) {
		variables._objects.ViewFinder.calls.append({removeMapping: [arguments.mapping]})
	}
	public void function clearViewMappings() {
		variables._objects.ViewFinder.calls.append({clear: []})
	}

	// Factory / wiring methods

	/**
	 * Flags the given object and the objects that depend on it for construction.
	 */
	private void function flagConstruction(required String object) {

		var object = arguments.object
		variables._objects[object].construct = true
		// Also construct objects that depend on this one.
		variables._dependencies.each(function (client, dependencies) {
			if (arguments.dependencies.find(object) > 0) {
				flagConstruction(arguments.client)
			}
		})

	}

	private CommandFactory function commandFactory() {
		var object = variables._objects.CommandFactory
		if (object.construct) {
			variables._commandFactory = new ContentCommandFactory(elementFactory(), viewFinder())
			object.construct = false
		}

		return variables._commandFactory
	}

	private EndPoint function endPoint() {
		var object = variables._objects.EndPoint
		if (object.construct) {
			variables._endPoint = new EndPoint()
			object.construct = false
		}

		return variables._endPoint
	}

	private ElementFactory function elementFactory() {
		var object = variables._objects.ElementFactory
		if (object.construct) {
			variables._elementFactory = new ElementFactory()
			object.construct = false
		}

		return variables._elementFactory
	}

	private PathSegmentFactory function pathSegmentFactory() {
		var object = variables._objects.PathSegmentFactory
		if (object.construct) {
			variables._pathSegmentFactory = new PathSegmentFactory()
			object.construct = false
		}

		return variables._pathSegmentFactory
	}

	private RoutesParser function routesParser() {
		var object = variables._objects.RoutesParser
		if (object.construct) {
			variables._routesParser = new RoutesParser(rootPathSegment(), pathSegmentFactory(), commandFactory())
			object.construct = false
		}

		return variables._routesParser
	}

	private TemplateFinder function templateFinder() {
		var object = variables._objects.TemplateFinder
		if (object.construct) {
			variables._extension = object.extension ?: variables._extension ?: "cfm"
			variables._templateFinder = new TemplateFinder(variables._extension)
			object.construct = false
		}

		return variables._templateFinder
	}

	private ViewFinder function viewFinder() {
		var object = variables._objects.ViewFinder
		if (object.construct) {
			variables._templateRenderer = object.templateRenderer ?: variables._templateRenderer ?: new CFMLRenderer()
			variables._viewFinder = new ViewFinder(templateFinder(), variables._templateRenderer)
			object.construct = false
		}

		return variables._viewFinder
	}

	private PathSegment function rootPathSegment() {
		if (!variables.keyExists("_rootPathSegment")) {
			variables._rootPathSegment = pathSegmentFactory().create("/")
		}

		return variables._rootPathSegment
	}

}