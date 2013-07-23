component extends="DocumentFoundation" implements="TemplateContent" {

	/**
	 * Returns an array containing all placeholders.
	 **/
	public Array function getPlaceholders() {

		var placeholders = []
		// get the placeholders from the parent template, keep the ones that aren't used and add any new ones
		for (var placeholder in getTemplate().getPlaceholders()) {
			var region = findRegion(placeholder)
			if (region == null) {
				// unused placeholder
				placeholders.append(placeholder)
			} else {
				// get the placeholders that are descendants of this region
				placeholders.append(region.getPlaceholders(), true)
			}
		}

		return placeholders
	}

}