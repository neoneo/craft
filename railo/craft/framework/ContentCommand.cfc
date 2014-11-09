import craft.markup.FileBuilder;

import craft.output.RenderVisitor;
import craft.output.ViewFactory;

import craft.request.Command;
import craft.request.Context;

/**
 * `Command` implementation that renders a `Content` instance, as defined by the given xml file.
 * The implementation only instantiates the `Content` upon first request.
 */
component implements="Command" {

	public void function init(required FileBuilder fileBuilder, required String path) {
		this.fileBuilder = arguments.fileBuilder
		this.path = arguments.path

		this.content = null
	}

	public Any function execute(required Context context) {

		if (this.content === null) {
			var element = this.fileBuilder.build(this.path)
			this.content = element.product
		}

		var visitor = new RenderVisitor(arguments.context)

		this.content.accept(visitor)

		return visitor.content;
	}

}