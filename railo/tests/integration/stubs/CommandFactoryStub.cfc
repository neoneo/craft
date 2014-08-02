import craft.core.request.Command;
import craft.core.request.CommandFactory;

component implements="CommandFactory" {

	public Command function supply(required String identifier) {
		return new CommandStub(identifier: arguments.identifier)
	}

}