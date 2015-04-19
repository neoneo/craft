import craft.markup.FileBuilder;
import craft.markup.Scope;

import craft.request.Command;
import craft.request.CommandFactory;

import craft.util.ObjectProvider;

/**
 * `CommandFactory` implementation that returns `ContentCommand` instances.
 *
 * @singleton
 */
component implements = CommandFactory accessors = true {

	property String path;

	this.path = ""

	public void function init(required ObjectProvider objectProvider, required Scope scope) {
		this.objectProvider = arguments.objectProvider
		this.fileBuilder = this.objectProvider.instance("FileBuilder", {scope: arguments.scope})
	}

	/**
	 * The identifier is the path to the xml file that defines the `Content`.
	 */
	public Command function create(required String identifier) {
		// Pass the file builder and the path. The command will use them when first requested.
		return this.objectProvider.instance("ContentCommand", {
			fileBuilder: this.fileBuilder,
			path: this.path & (arguments.identifier.startsWith("/") ? "" : "/") & arguments.identifier
		);
	}

}