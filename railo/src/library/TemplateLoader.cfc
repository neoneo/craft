import craft.core.content.Content;

import craft.xml.Element;
import craft.xml.ElementLoader;
import craft.xml.Loader;

component extends="Loader" {

	public Element[] function load(required String path) {

		var elements = []

		var nodes = []
		DirectoryList(arguments.path, true, "path", "*.xml").each(function (path) {
			nodes.append(XMLParse(FileRead(arguments.path)).xmlRoot)
		})

		while (!nodes.isEmpty()) {
			deferred = []

			for (var node in nodes) {
				if (!node.xmlAttributes.keyExists("extends") || hasElement(node.xmlAttributes.extends)) {
					var loader = new ElementLoader(factory(), this)
					var element = loader.load(node)[1]
					// All elements should be templates, with a required ref.
					keep(element)
					elements.append(element)
				} else {
					deferred.append(node)
				}
			}

			if (nodes.len() == deferred.len()) {
				Throw("Could not construct all elements", "ConstructionException")
			}

			nodes = deferred
		}

		return elements
	}

}