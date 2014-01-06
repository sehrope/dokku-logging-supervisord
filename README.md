# dokku-logging-supervisord

dokku-logging-supervisord is a plugin for [dokku][dokku] that injects
[supervisord][super] to run applications and redirects stdout/stderr to app specific log files (rather than the Docker default per-container JSON files). 

Thanks to [dokku-supervisord](https://github.com/statianzo/dokku-supervisord) and [dokku-persistent-storage](https://github.com/dyson/dokku-persistent-storage) as this plugin is really a combination of those two.

## What it does

Normally, dokku only runs the `web` process within Procfile. The
dokku-logging-supervisord plugin will run all process types (web, worker, etc.) and will restart crashed applications.

Additionally, it creates and binds a shared directory for each app from `/var/log/dokku/$APP` on the host machine to `/var/log/app` in the app's container. The supervisord config is setup to have each process in your Procfile send it's stdout and stderr to a separate file in that directory named `$PROCESS_NAME.$PROCESS_NUM.log`. Output for the  `supervisord` process itself (startup/shutdown notices, etc) will be logged to a file named `supervisor.log` in the same log directory.

## Requirements

This plugin uses the `docker-args` hook to inject the data volume argument. As such, at the moment it only works with the development version of Dokku. 

## Installation

```sh
# Create the directory to house the log files:
sudo mkdir -p /var/log/dokku
sudo chown dokku:dokku /var/log/dokku

# Install the plugin:
git clone https://github.com/sehrope/dokku-logging-supervisord.git /var/lib/dokku/plugins/logging-supervisord
```

All future deployments will use this plugin to start all processes and all log output will be in `/var/log/dokku/$APP/`.


## Example

If you have an app `myapp` with a Procfile that looks like this:

    web: node web.js
    worker: node worker.js

And you push your app with Dokku like this:

```sh
    $ git push dokku@example.org:myapp master
```

Then upon starting it you would have log files at:

    /var/log/dokku/myapp/supervisor.log
    /var/log/dokku/myapp/web.00.log
    /var/log/dokku/myapp/worker.00.log

## TODO

* Better handle log file rotation
* Add date/time to log output
* Add support for multiple of the same process type

## License

This plugin is released under the MIT license. See the file [LICENSE](LICENSE).

[dokku]: https://github.com/progrium/dokku
[super]: http://supervisord.org
