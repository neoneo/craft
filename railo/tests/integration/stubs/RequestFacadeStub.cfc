import craft.request.RequestFacade;

component extends="RequestFacade" {

	private Endpoint function createEndpoint() {
		 return new EndpointStub();
	}

	public Endpoint function getEndpoint() {
		return this.endpoint;
	}

}