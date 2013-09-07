component extends="craft.core.content.Component" {

	private String function view(required Context context) {
		return "before [[children]] after"
	}

}