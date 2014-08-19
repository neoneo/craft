component {

	public void function init(required CommandFactory commandFactory) {

		variables._endPoint = createEndPoint()
		var pathSegmentFactory = createPathSegmentFactory()
		variables._root = createRoot(pathSegmentFactory)
		variables._routesParser = createRoutesParser(variables._root, pathSegmentFactory, arguments.commandFactory)

	}

	public void function setRootPath(required String rootPath) {
		variables._endPoint.setRootPath(arguments.rootPath)
	}

	public void function importRoutes(required String mapping) {
		variables._routesParser.import(ExpandPath(arguments.mapping))
	}

	public void function purgeRoutes(required String mapping) {
		variables._routesParser.purge(ExpandPath(arguments.mapping))
	}

	public void function handleRequest() {
		try {
			var context = new Context(variables._endPoint, variables._root)
		} catch (FileNotFoundException e) {
			header statuscode="404";
			WriteOutput("404 not found")
			return;
		}

		var pathSegment = context.pathSegment()
		var method = context.requestMethod()

		if (pathSegment.hasCommand(method)) {
			var command = pathSegment.command(method)
			try {
				var output = command.execute(context)

				header statuscode="#context.getStatusCode()#";
				// content type="#context.getContentType()#; charset=#context.getCharacterSet()#";

				if (context.getDownloadAs() !== null) {
					header name="Content-Disposition" value="attachment; filename=#context.getDownloadAs()#";
				}

				switch (context.getContentType()) {
					case "application/json":
						if (IsArray(output) || IsStruct(output)) {
							output = SerializeJSON(output)
						}
						break;

					case "application/xml":
						if (IsXMLNode(output)) {
							output = ToString(output)
						}
						break;

					case "application/pdf":

						break;
				}

				if (IsBinary(output)) {
					content variable="#output#";
				} else if (context.getDownloadFile() !== null) {
					content file="#context.getDownloadFile()#" deletefile="#context.getDeleteFile() ?: false#";
				} else {
					WriteOutput(output)
				}
			} catch (Any e) {
				header statuscode="500";
				dump(e)
				return;
			}
		} else {
			header statuscode="405";
			WriteOutput("405 method not allowed")
			return;
		}

	}

	private EndPoint function createEndPoint() {
		return new EndPoint();
	}

	private PathSegmentFactory function createPathSegmentFactory() {
		return new PathSegmentFactory();
	}

	private PathSegment function createRoot(required PathSegmentFactory pathSegmentFactory) {
		return arguments.pathSegmentFactory.create("/");
	}

	private RoutesParser function createRoutesParser(required PathSegment root, required PathSegmentFactory pathSegmentFactory, required CommandFactory commandFactory) {
		return new RoutesParser(arguments.root, arguments.pathSegmentFactory, arguments.commandFactory);
	}

}