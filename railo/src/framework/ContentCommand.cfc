import craft.markup.FileBuilder;

import craft.output.RenderVisitor;
import craft.output.ViewFinder;

import craft.request.Command;
import craft.request.Context;

/**
 * `Command` implementation that renders a `Content` instance, as defined by the given xml file.
 * The implementation only instantiates the `Content` upon first request.
 */
component implements="Command" {

	public void function init(required FileBuilder fileBuilder, required String path, required ViewFinder viewFinder) {
		variables._fileBuilder = arguments.fileBuilder
		variables._path = arguments.path
		variables._viewFinder = arguments.viewFinder

		variables._content = null
	}

	public Any function execute(required Context context) {

		if (variables._content === null) {
			var element = variables._fileBuilder.build(variables._path)
			variables._content = element.product()
		}

		var visitor = new RenderVisitor(arguments.context, variables._viewFinder)

		variables._content.accept(visitor)

		return visitor.content();
	}

}