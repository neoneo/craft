import craft.framework.Console;

component extends="Console" {

	private Facade function createRequestFacade() {
		return new RequestFacadeStub(getCommandFactory());
	}

	public EndPoint function getEndPoint() {
		return this.requestFacade.getEndPoint()
	}

}