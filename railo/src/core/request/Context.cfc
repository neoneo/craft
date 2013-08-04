import craft.core.output.Renderer;

/**
 * Context
 *
 * @transient
 **/
component accessors="true" {

	property PathSegment pathSegment setter="false";
	property Struct parameters setter="false";
	property Extension extension setter="false";

	public void function init(required EndPoint endPoint, required Renderer renderer) {

		variables.endPoint = arguments.endPoint

		var info = arguments.endPoint.parse()
		variables.pathSegment = info.pathSegment
		variables.extension = info.extension
		variables.parameters = arguments.endPoint.getParameters()

		variables.renderer = arguments.renderer

	}

	public Struct function render(required String view, required Struct model) {
		return variables.renderer.render(arguments.view, arguments.model, getExtension())
	}

	public void function write() {

		var extension = getExtension()
		var output = getPathSegment().getContent().render(this)

		// insert region content
		/*for (var ref in variables.regions) {
			var content = extension.concatenate(variables.regions[ref])
			output = Replace(output, regionPlaceholder(ref), content)
		}*/

		content type="#extension.getMimeType()#";
		Echo(extension.convert(output))

	}

	public String function createUrl(required String path, Struct parameters, String extensionName) {
		return variables.endPoint.createUrl(argumentCollection = arguments.toStruct())
	}

	// public void function regionAppend(required String ref, required String output) {

	// 	if (!variables.regions.keyExists(arguments.ref)) {
	// 		variables.regions[arguments.ref] = []
	// 	}

	// 	variables.regions[arguments.ref].append(arguments.output)

	// }

}