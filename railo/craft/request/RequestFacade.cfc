component {

	public void function init(required CommandFactory commandFactory) {

		this.endpoint = this.createEndpoint()
		this.root = this.createRoot()
		this.routesParser = this.createRoutesParser(this.root, arguments.commandFactory)

	}

	public void function importRoutes(required String mapping) {
		this.routesParser.import(ExpandPath(arguments.mapping))
	}

	public void function purgeRoutes(required String mapping) {
		this.routesParser.purge(ExpandPath(arguments.mapping))
	}

	public void function handleRequest() {

		var context = new Context(this.endpoint, this.root)

		try {
			var output = context.handleRequest()

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
		} catch (BadRequestException e) {
			header statuscode="400" statustext="#e.message#";
		} catch (UnauthorizedException e) {
			header statuscode="401" statustext="#e.message#";
		} catch (ForbiddenException e) {
			header statuscode="403" statustext="#e.message#";
		} catch (NotFoundException e) {
			header statuscode="404" statustext="#e.message#";
		} catch (MethodNotAllowedException e) {
			header statuscode="405" statustext="#e.message#";
		}
	}

	private Endpoint function createEndpoint() {
		return new Endpoint();
	}

	private PathSegment function createRoot() {
		return new RootPathSegment();
	}

	private RoutesParser function createRoutesParser(required PathSegment root, required CommandFactory commandFactory) {
		return new RoutesParser(arguments.root, arguments.commandFactory);
	}

}