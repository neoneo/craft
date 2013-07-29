import craft.core.request.Context;

/**
 * Decorates a Node instance so that it can serve as Content.
 */
component implements="Content" {

	public void function init(required Node node) {
		variables.node = arguments.node
	}

	public String function render(required Context context) {
		variables.node.render(arguments.context)
	}

}