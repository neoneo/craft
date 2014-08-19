import craft.framework.Console;

component extends="Console" {

	private Facade function createRequestFacade() {
		return new RequestFacadeStub(commandFactory());
	}

	public EndPoint function endPoint() {
		return variables._requestFacade.endPoint()
	}

}