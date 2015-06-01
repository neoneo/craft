import craft.util.ObjectProvider;

/**
 * @singleton
 */
component {

	public void function init(required ObjectProvider objectProvider) {
		this.objectProvider = arguments.objectProvider
		this.routesParser = this.objectProvider.instance("RoutesParser")
		this.statusPaths = {}
	}

	public void function importRoutes(required String mapping) {
		this.routesParser.import(ExpandPath(arguments.mapping))
	}

	public void function purgeRoutes(required String mapping) {
		this.routesParser.purge(ExpandPath(arguments.mapping))
	}

	/**
	 * Maps the given status code to the given path.
	 */
	public void function mapStatusCode(required Numeric code, required String path) {
		this.statusPaths[arguments.code] = arguments.path
	}

	public void function handleRequest() {

		var context = this.objectProvider.instance("Context")

		try {
			var result = context.processRequest()

			header statuscode = context.statusCode;
			content type = "#context.contentType#; charset=#context.characterSet#";

			if (context.downloadAs !== null) {
				header name = "Content-Disposition" value = "attachment; filename=#context.downloadAs#";
			}

			var output = null
			switch (context.contentType) {
				case "text/html":
				case "text/plain":
					break;

				case "application/json":
					if (IsArray(result) || IsStruct(result) || IsSimpleValue(result) && !IsJSON(result)) {
						output = SerializeJSON(result)
					}
					break;

				case "application/xml":
					if (IsXMLNode(result)) {
						output = ToString(result)
					}
					break;

				case "application/pdf":
					document format = "pdf" name = "output" {
						WriteOutput(result)
					}
					break;
			}

			if (IsBinary(output)) {
				content variable = output;
			} else if (context.downloadFile !== null) {
				content file = context.downloadFile deletefile = (context.deleteFile ?: false);
			} else {
				WriteOutput(output)
			}
		} catch (BadRequestException e) {
			this.status(400, e.message)
		} catch (UnauthorizedException e) {
			this.status(401, e.message)
		} catch (ForbiddenException e) {
			this.status(403, e.message)
		} catch (NotFoundException e) {
			this.status(404, e.message)
		} catch (MethodNotAllowedException e) {
			this.status(405, e.message)
		}
	}

	private void function status(required Numeric code, String text = "") {
		content reset = true;
		header statuscode = arguments.code statustext = arguments.text;

		if (this.statusPaths.keyExists(arguments.code)) {
			WriteOutput(context.get(this.statusPaths[arguments.code]))
		}
	}

}