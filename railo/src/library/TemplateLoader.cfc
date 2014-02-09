import craft.core.content.Content;

import craft.xml.Element;
import craft.xml.ElementLoader;
import craft.xml.Loader;

component extends="Loader" {

	public Struct function load(required String path) {

		var contents = {}

		var nodes = {}
		DirectoryList(arguments.path, true, "path", "*.xml").each(function (path) {
			// Only include templates.
			var node = XMLParse(FileRead(arguments.path)).xmlRoot
			if (isTemplate(node)) {
				nodes[arguments.path] = node
			}
		})

		while (!nodes.isEmpty()) {
			deferred = {}

			for (var path in nodes) {
				var node = nodes[path]
				if (!node.xmlAttributes.keyExists("extends") || hasElement(node.xmlAttributes.extends)) {
					var loader = new ElementLoader(factory(), this)
					var element = loader.load(node)[1]
					// All elements should be templates, with a required ref. We keep all of them available.
					keep(element)
					contents[path] = element.product()
				} else {
					deferred[path] = node
				}
			}

			if (nodes.len() == deferred.len()) {
				Throw("Could not construct all elements", "ConstructionException")
			}

			nodes = deferred
		}

		return contents
	}

	private Boolean function isTemplate(required XML node) {
		return arguments.node.xmlName == "template" || arguments.node.xmlName == "documenttemplate"
	}

}