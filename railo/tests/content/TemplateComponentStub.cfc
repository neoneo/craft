component extends="craft.core.content.TemplateComponent" {

	private String function view(required Context context) {
		return "before [[children]] after"
	}

}