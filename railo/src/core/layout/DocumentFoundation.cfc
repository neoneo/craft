component implements="Content" accessors="true" {

	property TemplateContent template;

	public void function init(required TemplateContent template) {
		variables.template = arguments.template
		// use a hashmap so that we can use placeholder objects for keys
		variables.regions = CreateObject("java", "java.util.HashMap").init()
	}

	public String function render(required Context context) {

		var output = getTemplate().render(arguments.context)

		var regions = getRegions()
		for (var placeholder in regions) {
			output = Replace(output, placeholder.getInsert(), regions.get(placeholder).render(arguments.context))
		}

		return output
	}

	public void function addRegion(required Placeholder placeholder, required Region region) {

		var regions = getRegions()
		if (!regions.containsKey(arguments.placeholder)) {
			regions.put(arguments.placeholder, arguments.region)
		}

	}

	/**
	 * Removes the nodes for the given region.
	 **/
	public void function removeRegion(required Placeholder placeholder) {
		getRegions().remove(arguments.placeholder)
	}

	private void function setTemplate(required TemplateContent template) {
		variables.template = arguments.template
	}

	private Struct function getRegions() {
		return variables.regions
	}

}