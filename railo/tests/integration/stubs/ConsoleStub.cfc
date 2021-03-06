import craft.framework.Console;

component extends="Console" {

	private Facade function createRequestFacade() {
		return new RequestFacadeStub(getCommandFactory());
	}

	public Endpoint function getEndpoint() {
		return this.requestFacade.getEndpoint()
	}

}