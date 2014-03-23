component {

	public void function init(required String id, required Struct config, required DirectoryListener listener) {
		variables._state = "stopped"
		variables._id = arguments.id
		variables._config = arguments.config
		variables._listener = arguments.listener

		variables._methods = {
			ENTRY_CREATE: "entryCreated",
			ENTRY_MODIFY: "entryModified",
			ENTRY_DELETE: "entryDeleted"
		}
	}

	public void function start() {

		lock name="DirectoryWatcherGateway#variables._id#" type="exclusive" timeout="10" {
			if (variables._state != "running") {
				variables._state = "running"
				var directory = variables._config.directory & (variables._config.recursive ? " (recursively)" : "")
				log log="application" type="information" text="directory watcher gateway: starting";
				try {
					var watcher = new DirectoryWatcher(variables._config.directory, variables._config.recursive)
					log log="application" type="information" text="directory watcher gateway: watching #directory#";

					running:while (variables._state == "running") {
						var events = watcher.poll()
						if (!events.isEmpty()) {
							for (var event in events) {
								var method = variables._methods[event.type]
								variables._listener[method](event.file)
							}
						}

						// Sleep until the next run, but cut it into half seconds, so we can stop the gateway easily.
						var sleepStep = 500
						var time = 0
						while (time < variables._config.interval) {
							sleepStep = Min(sleepStep, variables._config.interval - time)
							time += sleepStep
							Sleep(sleepStep)
							if (variables._state != "running") {
								break running;
							}
						}
					}
				} catch (Any e) {
					log log="application" type="error" text="directory watcher gateway: #e.type# #e.message#";
				} finally {
					if (!IsNull(watcher)) {
						watcher.close()
					}
					variables._state = "stopped"
					log log="application" type="information" text="directory watcher gateway: stopped watching #directory#");
				}
			}
		}

	}

	public void function stop() {
		if (variables._state == "running") {
			variables._state = "stopping"
			log log="application" type="information" text="directory watcher gateway: stopping";
		}
	}

	public void function restart() {
		stop()
		start()
	}

	public String function getState() {
		return variables._state
	}

	public String function sendMessage(required Struct data) {
		Throw("Not supported")
	}

}