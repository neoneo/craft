import craft.core.content.Content;

import craft.xml.Builder;
import craft.xml.Element;
import craft.xml.ElementFactory;
import craft.xml.Repository;

component {

	public void function init(required ElementFactory factory, required Repository repository) {
		variables._factory = arguments.factory
		variables._repository = arguments.repository
		variables._builder = new Builder(variables._repository)
	}

	public Struct function load(required String path) {

		var elements = {}

		// Templates can extend one another. First fill elements with all the template documents.
		DirectoryList(arguments.path, true, "path", "*.xml").each(function (path) {
			var node = XMLParse(FileRead(arguments.path)).xmlRoot
			/*
				Only include templates. We assume that all or most of the documents are templates so that constructing the complete
				element tree for each of them is not costly.
			*/
			var element = variables._factory.construct(node)
			if (isTemplate(element)) {
				elements[arguments.path] = element
			}
		})

		// Keep traversing the elements until all have been constructed successfully. With every iteration, the struct should become smaller.
		var remaining = Duplicate(elements, false)
		while (!remaining.isEmpty()) {
			deferred = {}

			for (var path in remaining) {
				var element = remaining[path]
				if (canLoad(element)) {
					builder.build(element)
					// All elements are templates, with a required ref. We keep all of them available.
					variables._repository.store(element)
					contents[path] = element
				} else {
					deferred[path] = element
				}
			}

			if (remaining.len() == deferred.len()) {
				Throw("Could not construct all elements", "ConstructionException")
			}

			remaining = deferred
		}

		return elements
	}

	/**
	 * Returns true if the `Element` is a template.
	 */
	private Boolean function isTemplate(required Element element) {
		return IsInstanceOf(arguments.element, "TemplateElement") || IsInstanceOf(arguments.element, "DocumentTemplateElement")
	}

	/**
	 * Returns true if the `Element` is ready to be loaded, that is, if all its dependencies are available.
	 */
	private Boolean function canLoad(required Element element) {
		if (IsInstanceOf(arguments.element, "TemplateElement")) {
			return true
		} else {
			return IsNull(arguments.element.getExtends()) || variables._repository.hasElement(arguments.element.getExtends())
		}
	}

}