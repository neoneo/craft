component {

	public void function init(required String directory, Boolean recursive = false) {

		var file = CreateObject("java", "java.io.File").init(arguments.directory)
		if (!file.isDirectory()) {
			Throw("Directory '#arguments.directory#' does not exist or is not a directory", "FileNotFoundException")
		}

		this.watcher = CreateObject("java", "java.nio.file.FileSystems").getDefault().newWatchService()
		this.keys = CreateObject("java", "java.util.HashMap").init() // We can't use a struct because the keys are not strings.
		this.recursive = arguments.recursive

		this.kinds = CreateObject("java", "java.nio.file.StandardWatchEventKinds")

		register(file.toPath(), arguments.recursive)

	}

	public Struct[] function poll() {
		return handleEvents(this.watcher.poll());
	}

	public Struct[] function take() {
		return handleEvents(this.watcher.take());
	}

	public void function close() {
		this.watcher.close()
	}

	private Struct[] function handleEvents(required Any key = null) {

		var events = []
		if (arguments.key !== null) {
			var path = this.keys.get(arguments.key)
			if (path === null) {
				for (var event in arguments.key.pollEvents()) {
					var kind = event.kind()
					if (kind !== this.kinds.OVERFLOW) {
						var relativePath = event.context()
						/*
							In the case of ENTRY_CREATE, ENTRY_DELETE, and ENTRY_MODIFY events, the context is a Path that is the relative path between the
							directory registered with the watch service, and the entry that is created, deleted, or modified.
						*/
						var affectedPath = path.resolve(relativePath)
						var file = affectedPath.toFile()

						if (this.recursive && kind === this.kinds.ENTRY_CREATE) {
							if (file.isDirectory()) {
								register(affectedPath, this.recursive)
							}
						}

						events.append({type: kind.name(), file: file})
					}
				}

				var valid = arguments.key.reset()
				if (!valid) {
					this.keys.remove(arguments.key)
				}
			}
		}

		return events;
	}

	private void function register(required Any path, required Boolean recursive) {

		var key = arguments.path.register(this.watcher, [this.kinds.ENTRY_CREATE, this.kinds.ENTRY_MODIFY, this.kinds.ENTRY_DELETE])
		this.keys.put(key, arguments.path)

		if (arguments.recursive) {
			var files = arguments.path.toFile().listFiles()
			for (var file in files) {
				if (file.isDirectory()) {
					register(file.toPath(), arguments.recursive)
				}
			}
		}

	}

}