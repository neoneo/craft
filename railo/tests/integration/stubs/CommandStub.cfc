import craft.request.Command;
import craft.request.Context;

component implements="Command" accessors="true" {

	property String identifier;

	public Any function execute(required Context context) {
		return this.identifier;
	}

}