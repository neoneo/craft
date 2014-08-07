import craft.content.Content;

import craft.output.RenderVisitor;
import craft.output.ViewFinder;

import craft.request.Command;
import craft.request.Context;

component implements="Command" {

	public void function init(required Content content, required ViewFinder viewFinder) {
		variables._content = arguments.content
		variables._viewFinder = arguments.viewFinder
	}

	public Any function execute(required Context context) {

		var visitor = new RenderVisitor(arguments.context, variables._viewFinder)

		variables._content.accept(visitor)

		return visitor.content()
	}

}