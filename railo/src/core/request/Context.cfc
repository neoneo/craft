import craft.core.layout.Content;
import craft.core.output.ViewInventory;
import craft.core.output.Extension;
import craft.core.output.Renderer;

/**
 * Context
 *
 * @transient
 **/
component accessors="true" {

	property Content content setter="false";
	property Struct parameters setter="false";
	property Extension extension setter="false";

	public void function init(required Content content, required Struct parameters, required Extension extension, required Renderer renderer) {

		variables.content = arguments.content
		variables.parameters = arguments.parameters
		//variables.viewInventory = arguments.viewInventory
		variables.renderer = arguments.renderer
		variables.extension = arguments.extension

	}

	public Struct function render(required String view, required Struct model) {

		return variables.renderer.render(arguments.view, arguments.model, getExtension())

		// the view inventory returns the name of the template and the extension that is rendered by the template
		// var data = variables.viewInventory.get(arguments.view, variables.context.getExtension())
		// var template = data.template
		// var extension = data.extension

		// return {
		// 	output = variables.renderer.render(template, arguments.model),
		// 	extension = extension
		// }
	}

	public void function write() {

		var extension = getExtension()
		var output = getContent().render(this)

		// insert region content
		/*for (var ref in variables.regions) {
			var content = extension.concatenate(variables.regions[ref])
			output = Replace(output, regionPlaceholder(ref), content)
		}*/

		content type="#extension.getMimeType()#";
		Echo(extension.convert(output))

	}

	public String function createUrl(required String path, Struct parameters, String extensionName) {
		return variables.requestStrategy.createUrl(argumentCollection = arguments.toStruct())
	}

	// public void function regionAppend(required String ref, required String output) {

	// 	if (!variables.regions.keyExists(arguments.ref)) {
	// 		variables.regions[arguments.ref] = []
	// 	}

	// 	variables.regions[arguments.ref].append(arguments.output)

	// }

}