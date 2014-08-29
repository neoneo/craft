import craft.request.Command;
import craft.request.Context;

component implements="Command" accessors="true" {

	property String identifier;

	public Any function execute(required Context context) {
		return {
			command: this.identifier,
			method: arguments.context.requestMethod,
			path: arguments.context.path,
			extension: arguments.context.extension,
			parameters: arguments.context.parameters
		}
	}

}