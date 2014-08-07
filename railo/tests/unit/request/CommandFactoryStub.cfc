import craft.request.*;

component implements="CommandFactory" {

	public Command function supply(required String identifier) {
		return new CommandStub(identifier: arguments.identifier)
	}

}