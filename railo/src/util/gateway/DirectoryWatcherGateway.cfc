component {

	public void function init(required String id, required Struct config, required DirectoryListener listener) {
		this.state = "stopped"
		this.id = arguments.id
		this.config = arguments.config
		this.listener = arguments.listener

		this.methods = {
			ENTRY_CREATE: "entryCreated",
			ENTRY_MODIFY: "entryModified",
			ENTRY_DELETE: "entryDeleted"
		}
	}

	public void function start() {

		lock name="DirectoryWatcherGateway#this.id#" type="exclusive" timeout="10" {
			if (this.state != "running") {
				this.state = "running"
				var directory = this.config.directory & (this.config.recursive ? " (recursively)" : "")
				log log="application" type="information" text="directory watcher gateway: starting";

				var watcher = null
				try {
					watcher = new DirectoryWatcher(this.config.directory, this.config.recursive)
					log log="application" type="information" text="directory watcher gateway: watching #directory#";

					running:while (this.state == "running") {
						var events = watcher.poll()
						if (!events.isEmpty()) {
							for (var event in events) {
								var method = this.methods[event.type]
								this.listener[method](event.file)
							}
						}

						// Sleep until the next run, but cut it into half seconds, so we can stop the gateway easily.
						var sleepStep = 500
						var time = 0
						while (time < this.config.interval) {
							sleepStep = Min(sleepStep, this.config.interval - time)
							time += sleepStep
							Sleep(sleepStep)
							if (this.state != "running") {
								break running;
							}
						}
					}
				} catch (Any e) {
					log log="application" type="error" text="directory watcher gateway: #e.type# #e.message#";
				} finally {
					if (watcher !== null) {
						watcher.close()
					}
					this.state = "stopped"
					log log="application" type="information" text="directory watcher gateway: stopped watching #directory#");
				}
			}
		}

	}

	public void function stop() {
		if (this.state == "running") {
			this.state = "stopping"
			log log="application" type="information" text="directory watcher gateway: stopping";
		}
	}

	public void function restart() {
		stop()
		start()
	}

	public String function getState() {
		return this.state
	}

	public String function sendMessage(required Struct data) {
		Throw("Not supported")
	}

}