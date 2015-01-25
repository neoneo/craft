import craft.content.Composite;

import craft.request.Context;

component extends="Composite" {

	private void function configure(required String[] spans, String[] offsets = [], String[] pulls = []) {
		this.viewObject = this.viewRepository.create("bootstrap/view/column", {
			spans: arguments.spans,
			offsets: arguments.offsets,
			pulls: arguments.pulls
		})
	}

	public Any function view(required Context context) {
		return this.viewObject;
	}

	public Any function process(required Context context) {
		return null;
	}


}