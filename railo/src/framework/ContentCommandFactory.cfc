import craft.markup.ElementFactory;

import craft.output.ViewFinder;

import craft.request.Command;
import craft.request.CommandFactory;

component implements="CommandFactory" {

	variables._path = null // The path to the directory where the commands are located.

	public void function init(required ElementFactory elementFactory, required ViewFinder viewFinder) {
		variables._elementFactory = arguments.elementFactory
		variables._viewFinder = arguments.viewFinder
		variables._commands = {}
	}

	public void function setPath(required String path) {
		variables._path = arguments.path
	}

	public void function clear() {
		variables._commands.clear()
	}

	/**
	 * The identifier is the path to the xml file that defines the `Content`.
	 */
	public Command function supply(required String identifier) {

		if (variables._commands.keyExists(arguments.identifier)) {
			return variables._commands[arguments.identifier]
		} else {
			var builder = new FileBuilder(variables._elementFactory)
			var element = builder.build(variables._path & "/" & arguments.identifier)
			var content = element.product()

			var command = new ContentCommand(content, variables._viewFinder)
			variables._commands[arguments.identifier] = command

			return command
		}
	}

}