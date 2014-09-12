import craft.request.*;

component implements="CommandFactory" {

	public Command function create(required String identifier) {
		return new CommandStub(identifier: arguments.identifier)
	}

}