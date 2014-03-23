component {

	public void function init(required String directory, Boolean recursive = false) {

		var file = CreateObject("java", "java.io.File").init(arguments.directory)
		if (!file.isDirectory()) {
			Throw("Directory '#arguments.directory#' does not exist or is not a directory", "FileNotFoundException")
		}

		variables._watcher = CreateObject("java", "java.nio.file.FileSystems").getDefault().newWatchService()
		variables._keys = CreateObject("java", "java.util.HashMap").init() // We can't use a struct because the keys are not strings.
		variables._recursive = arguments.recursive

		variables._kinds = CreateObject("java", "java.nio.file.StandardWatchEventKinds")

		register(file.toPath(), arguments.recursive)

	}

	public Array function poll() {
		return handleEvents(variables._watcher.poll())
	}

	public Array function take() {
		return handleEvents(variables._watcher.take())
	}

	public void function close() {
		variables._watcher.close()
	}

	private Array function handleEvents(required Any key) {

		var events = []
		if (!IsNull(arguments.key)) {
			var path = variables._keys.get(arguments.key)
			if (!IsNull(path)) {
				for (var event in arguments.key.pollEvents()) {
					var kind = event.kind()
					if (kind !== variables._kinds.OVERFLOW) {
						var relativePath = event.context()
						/*
							In the case of ENTRY_CREATE, ENTRY_DELETE, and ENTRY_MODIFY events, the context is a Path that is the relative path between the
							directory registered with the watch service, and the entry that is created, deleted, or modified.
						*/
						var affectedPath = path.resolve(relativePath)
						var file = affectedPath.toFile()

						if (variables._recursive && kind === variables._kinds.ENTRY_CREATE) {
							if (file.isDirectory()) {
								register(affectedPath, variables._recursive)
							}
						}

						events.append({type: kind.name(), file: file})
					}
				}

				var valid = arguments.key.reset()
				if (!valid) {
					variables._keys.remove(arguments.key)
				}
			}
		}

		return events
	}

	private void function register(required Any path, required Boolean recursive) {

		var key = arguments.path.register(variables._watcher, [variables._kinds.ENTRY_CREATE, variables._kinds.ENTRY_MODIFY, variables._kinds.ENTRY_DELETE])
		variables._keys.put(key, arguments.path)

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