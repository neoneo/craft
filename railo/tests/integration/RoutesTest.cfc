import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		content type="text/html" reset="false";

		this.endpoint = new stubs.EndpointStub()
		var pathSegmentFactory = new PathSegmentFactory()
		this.rootPathSegment = pathSegmentFactory.create("/")
		this.parser = new RoutesParser(this.rootPathSegment, pathSegmentFactory, new stubs.CommandFactoryStub())

		this.parser.import(ExpandPath("/tests/integration/test.routes"))
	}

	public void function Root() {
		var result = testRequest("GET", "/")
		assertEquals({
			command: "Root",
			method: "GET",
			path: "/",
			extension: "html",
			parameters: null
		}, result)
	}

	public void function ArtistList() {
		var result = testRequest("GET", "/artists")
		assertEquals({
			command: "ArtistList",
			method: "GET",
			path: "/artists",
			extension: "html",
			parameters: null
		}, result)

		var result = testRequest("GET", "/artists.xml")
		assertEquals({
			command: "ArtistList",
			method: "GET",
			path: "/artists.xml",
			extension: "xml",
			parameters: null
		}, result)
	}

	public void function Artist() {
		var result = testRequest("GET", "/artists/1")
		assertEquals({
			command: "Artist",
			method: "GET",
			path: "/artists/1",
			extension: "html",
			parameters: {
				artist: 1
			}
		}, result)
	}

	public void function ArtistPicture() {
		var result = testRequest("GET", "/artists/1/picture")
		assertEquals({
			command: "Artist",
			method: "GET",
			path: "/artists/1/picture",
			extension: "html",
			parameters: {
				artist: 1,
				action: "picture"
			}
		}, result)
	}

	public void function Song() {
		var result = testRequest("GET", "/artists/1/albums/2/songs/3.json")
		assertEquals({
			command: "Song",
			method: "GET",
			path: "/artists/1/albums/2/songs/3.json",
			extension: "json",
			parameters: {
				artist: 1,
				album: 2,
				song: 3
			}
		}, result)
	}

	public void function NotFound() {
		try {
			var result = testRequest("GET", "/artists/1/notexist")
			fail("exception should have been thrown")
		} catch (FileNotFoundException e) {}
	}

	private Struct function testRequest(required String method, required String path, Struct parameters) {

		this.endpoint.setTestRequestMethod(arguments.method)
		this.endpoint.setTestPath(arguments.path)

		var parameters = arguments.parameters ?: null
		if (parameters !== null) {
			this.endpoint.setTestParameters(parameters)
		}

		var context = new Context(this.endpoint, this.rootPathSegment)
		var pathSegment = context.pathSegment
		var command = pathSegment.command(arguments.method)

		return command.execute(context)
	}

}