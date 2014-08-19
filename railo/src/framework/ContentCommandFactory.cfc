import craft.markup.ElementFactory;
import craft.markup.FileBuilder;
import craft.markup.Scope;

import craft.output.ViewFinder;

import craft.request.Command;
import craft.request.CommandFactory;

/**
 * `CommandFactory` implementation that returns `ContentCommand` instances.
 */
component implements="CommandFactory" {


	public void function init(required ElementFactory elementFactory, required Scope scope, required ViewFinder viewFinder) {
		variables._elementFactory = arguments.elementFactory
		variables._scope = arguments.scope
		variables._viewFinder = arguments.viewFinder

		variables._fileBuilder = new FileBuilder(variables._elementFactory, variables._scope)
		variables._commands = {}
		variables._path = null
	}

	/**
	 * Sets the path to the root folder where the xml documents are stored.
	 */
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
			return variables._commands[arguments.identifier];
		} else {
			// Pass the file builder and the path. The command will use them when first requested.
			var command = new ContentCommand(variables._fileBuilder, variables._path & "/" & arguments.identifier, variables._viewFinder)

			variables._commands[arguments.identifier] = command

			return command;
		}
	}

}