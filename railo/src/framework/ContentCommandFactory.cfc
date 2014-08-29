import craft.markup.ElementFactory;
import craft.markup.FileBuilder;
import craft.markup.Scope;

import craft.output.ViewFinder;

import craft.request.Command;
import craft.request.CommandFactory;

/**
 * `CommandFactory` implementation that returns `ContentCommand` instances.
 */
component implements="CommandFactory" accessors="true" {

	property String path;

	public void function init(required ElementFactory elementFactory, required Scope scope, required ViewFinder viewFinder) {
		this.elementFactory = arguments.elementFactory
		this.scope = arguments.scope
		this.viewFinder = arguments.viewFinder

		this.fileBuilder = new FileBuilder(this.elementFactory, this.scope)
		this.commands = {}
		this.path = null
	}

	public void function clear() {
		this.commands.clear()
	}

	/**
	 * The identifier is the path to the xml file that defines the `Content`.
	 */
	public Command function supply(required String identifier) {

		if (this.commands.keyExists(arguments.identifier)) {
			return this.commands[arguments.identifier];
		} else {
			// Pass the file builder and the path. The command will use them when first requested.
			var command = new ContentCommand(this.fileBuilder, this.path & "/" & arguments.identifier, this.viewFinder)

			this.commands[arguments.identifier] = command

			return command;
		}
	}

}