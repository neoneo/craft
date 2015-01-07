import craft.markup.TagRepository;
import craft.markup.FileBuilder;
import craft.markup.Scope;

import craft.request.Command;
import craft.request.CommandFactory;

/**
 * `CommandFactory` implementation that returns `ContentCommand` instances.
 */
component implements="CommandFactory" accessors="true" {

	property String path;

	this.path = ""

	public void function init(required TagRepository tagRepository, required Scope scope) {
		this.tagRepository = arguments.tagRepository
		this.scope = arguments.scope

		this.fileBuilder = new FileBuilder(this.tagRepository, this.scope)
	}

	/**
	 * The identifier is the path to the xml file that defines the `Content`.
	 */
	public Command function create(required String identifier) {
		// Pass the file builder and the path. The command will use them when first requested.
		return new ContentCommand(this.fileBuilder, this.path & (arguments.identifier.startsWith("/") ? "" : "/") & arguments.identifier);
	}

}