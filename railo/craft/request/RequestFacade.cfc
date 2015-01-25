component {

	public void function init(required CommandFactory commandFactory) {

		this.endpoint = createEndpoint()
		var pathSegmentFactory = createPathSegmentFactory()
		this.root = createRoot(pathSegmentFactory)
		this.routesParser = createRoutesParser(this.root, pathSegmentFactory, arguments.commandFactory)

	}

	public void function importRoutes(required String mapping) {
		this.routesParser.import(ExpandPath(arguments.mapping))
	}

	public void function purgeRoutes(required String mapping) {
		this.routesParser.purge(ExpandPath(arguments.mapping))
	}

	public void function handleRequest() {

		try {
			var context = new Context(this.endpoint, this.root)

			var pathSegment = context.pathSegment
			var method = context.requestMethod

			if (pathSegment.hasCommand(method)) {
				var command = pathSegment.command(method)
				var output = command.execute(context)

				header statuscode="#context.statusCode#";
				content type="#context.contentType#; charset=#context.characterSet#";

				if (context.downloadAs !== null) {
					header name="Content-Disposition" value="attachment; filename=#context.downloadAs#";
				}

				switch (context.contentType) {
					case "text/html":
						// TODO: dependencies
						break;

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
				} else if (context.downloadFile !== null) {
					content file="#context.downloadFile#" deletefile="#context.deleteFile ?: false#";
				} else {
					WriteOutput(output)
				}
			} else {
				header statuscode="405" statustext="Method not allowed";
			}
		} catch (BadRequestException e) {
			header statuscode="400" statustext="#e.message#";
		} catch (UnauthorizedException e) {
			header statuscode="401" statustext="#e.message#";
		} catch (ForbiddenException e) {
			header statuscode="403" statustext="#e.message#";
		} catch (NotFoundException e) {
			header statuscode="404" statustext="#e.message#";
		}

	}

	private Endpoint function createEndpoint() {
		return new Endpoint();
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