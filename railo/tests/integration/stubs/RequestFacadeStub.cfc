import craft.request.*;

component extends="Facade" {

	private Endpoint function createEndpoint() {
		 return new EndpointStub();
	}

	public Endpoint function getEndpoint() {
		return this.endpoint;
	}

}