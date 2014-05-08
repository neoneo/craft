import craft.core.request.PathSegment;
import craft.core.content.Content;

component {

	public void function init(required String rootFolder, required ElementFactory factory, String defaultName = "index") {
		variables.rootFolder = arguments.rootFolder
		variables.factory = arguments.factory
		variables.defaultName = arguments.defaultName
	}

	public Content function buildContent(required String path) {

		var element = XmlParse(FileRead(getRootFolder() & arguments.path))

		return factory().create(element)
	}

	/**
	 * Builds the content of the application recursively, starting at the given path.
	 * If no path is specified, the complete application is built from the root.
	 */
	public PathSegment function build(String path = "") {

		var pathSegment = createPathSegment(ListLast(arguments.path, "/"))

		// Get the listing as a query, so that we can differentiate between files and directories.
		var listing = DirectoryList(variables.rootFolder & "/" & arguments.path, false, "query", "*", "name asc")
		// Add a column for the segment name, based on the file name.
		var segmentNames = listing.columnData("name", function (name) {
			// Convert the file name to a segment name
			if (ListLast(arguments.name, ".") == "xml") {
				var partCount = ListLen(arguments.name, ".")
				/*
					The name can be of the forms:
					- <name>.xml
					- <name>.<method>.xml
					- <name>.<method>.<type>.xml
				*/

				// Remove the extension from the file name
				var data = {
					name: ListFirst(arguments.name, ".")
				}
				if (partCount > 2) {
					data.method = ListGetAt(arguments.name, 2, ".")
				}
				if (partCount > 3) {
					data.type = ListGetAt(arguments.name, 3, ".")
				}
				arguments.name = ListDeleteAt(arguments.name, partCount - 1, ".")

				return arguments.name
			} else {
				// return all other names unchanged
				return {}
			}
		})
		listing.addColumn("segmentName", segmentNames)

		// loop over the files grouped by segment name
		loop query="#listing#" group="segmentName" {
			switch (listing.type) {
				case "File":
					// this has to be an xml file
					if (ListLast(listing.name, ".") == "xml") {
						// there can be multiple files with the same segment name
						// the content in those files has to be added to the same path segment
						var childPathSegment = createPathSegment(listing.segmentName)

						loop {
							// construct the content instance
							var content = buildContent(arguments.path & "/" & listing.name)

							// determine the content type
							// the content type is the part before the extension, which should always be present
							var contentType = ListGetAt(listing.name, ListLen(listing.name, ".") - 1, ".")
							childPathSegment.setContent(contentType, content)

							if (listing.segmentName == getDefaultName()) {
								// <defaultName>.*.xml is the default content served by the current path segment
								// in effect this overwrites the content that might be defined in the parent folder, in a file with the same name as the current folder
								pathSegment.setContent(contentType, content)
							}
						}

						pathSegment.addChild(childPathSegment)

					}
					break

				case "Dir":
					pathSegment.addChild(buildFolder(arguments.path & "/" & listing.name))
					break
			}
		}

		return pathSegment
	}

	public PathSegment function createPathSegment(required String name) {

		var segmentName = arguments.name
		// Segment name can be of the form: pattern@parameter
		if (arguments.name contains "@") {
			// The last part is the parameter name.
			var parameterName = ListLast(arguments.name, "@")
			// The first part is the segment name.
			// Locate the last @.
			var index = Len(arguments.name) - Len(parameterName)
			// If @ is the first character, the segment name is a pattern that matches everything.
			segmentName = index > 1 ? Left(arguments.name, index - 1) : ".*"
		}

		if (Len(segmentName) == 0) {
			// This is the root path segment.
			return new RootPathSegment()
		} else if (FindOneOf("[(*?^$|", segmentName) > 0) {
			// Interpret the segment name as a pattern. Return a dynamic path segment.
			return new DynamicPathSegment(pattern = segmentName, parameterName = parameterName)
		} else {
			// Static path segment.
			return new StaticPathSegment(name = segmentName, parameterName = parameterName)
		}
	}

}