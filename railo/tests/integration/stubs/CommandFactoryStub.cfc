import craft.request.Command;
import craft.request.CommandFactory;

component implements="CommandFactory" {

	public Command function create(required String identifier) {
		return new CommandStub(identifier: arguments.identifier)
	}

}