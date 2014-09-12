import craft.markup.ElementFactory;
import craft.markup.FileBuilder;
import craft.markup.Scope;

import craft.request.Command;
import craft.request.CommandFactory;

/**
 * `CommandFactory` implementation that returns `ContentCommand` instances.
 */
component implements="CommandFactory" accessors="true" {

	property String path;

	public void function init(required ElementFactory elementFactory, required Scope scope) {
		this.elementFactory = arguments.elementFactory
		this.scope = arguments.scope

		this.fileBuilder = new FileBuilder(this.elementFactory, this.scope)
		this.path = null
	}

	/**
	 * The identifier is the path to the xml file that defines the `Content`.
	 */
	public Command function create(required String identifier) {

		// Pass the file builder and the path. The command will use them when first requested.
		var command = new ContentCommand(this.fileBuilder, this.path & "/" & arguments.identifier)

		this.commands[arguments.identifier] = command

		return command;
	}

}