# dokku-logging-supervisord

dokku-logging-supervisord is a plugin for [dokku][dokku] that injects
[supervisord][super] to run applications and redirects stdout & stderr to app/process specific log files (rather than the Docker default per-container JSON files). 

## Requirements

This plugin uses the `docker-args` hook to inject the data volume argument. As such, at the moment it only works with the development version of Dokku. 

## Installation

```sh
git clone https://github.com/sehrope/dokku-logging-supervisord.git /var/lib/dokku/plugins/logging-supervisord
dokku plugins-install
```

All future deployments will use this plugin to start all processes and all log output will be in `/var/log/dokku/$APP/`.
Logs are rotated. You may customize logrotate file after deploy, check `/etc/logrotate.d/dokku-app.d/$APP` file.

## What it does

Normally, dokku only runs the `web` process within Procfile. The
dokku-logging-supervisord plugin will run all process types (web, worker, etc.) and will restart crashed applications.

Additionally, it creates and binds a shared directory for each app from `/var/log/dokku/$APP` on the host machine to `/var/log/app` in the app's container. The supervisord config is setup to have each process in your Procfile send it's stdout and stderr to a separate file in that directory named `$PROCESS_NAME.$PROCESS_NUM.log`. Output for the  `supervisord` process itself (startup/shutdown notices, etc) will be logged to a file named `supervisor.log` in the same log directory.

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

## Scaling

This plugin supports running multiple of the same process type. At start it checks for a file in the apps home diretory named `SCALE`. The file should be a series of lines of the form `name=<num>` where `name` is the process name and `<num>` is the number of processes of that type to start.

Example:

    web=1
    worker=5
    clock=1

If the file does not exist then a single process of each type will be created for each process type in Procfile. Additional lines in the file ignored.

Logs for each process will go to separate log file in `/var/log/dokku/$APP/process.<num>.log`

__Note:__ All the processes will run in same Docker container. They do *not* run in separate containers. This means that if you have multiple "web" processes they will each try to listen on the same `PORT` environment variable. For this to work properly you should use the socket option [SO_REUSEPORT](https://lwn.net/Articles/542629/). If that is not available then you will need to stick with a single web process.

Rather than editing the file manually you can use the command:

    dokku scale myapp web=1 worker=6

This will generate a new `SCALE` file and then deploy the app. An app rebuild will __not__ happen. It will just kill and restart your application.

Adding the `SCALE` file is done by copying it into the container. This adds another layer to the container's AUFS. As there is a max number of layers you may need to occasionally run a rebuild (try `dokku rebuild myapp`) to rebase the container.

## Logrotate

This plugin create in directory "/etc/logrotate.d/dokku-app.d" logrotate config for each application.
If application destroyed, config will be removed only if user don't change it (in app root directory, md5 checksum of config file stored).

## TODO

* Better handle log file rotation
* Add date/time to log output
* Have the application runner see the scale file on the host so we don't have to copy it (volume mount?)

## Thanks

Thanks to [dokku-supervisord](https://github.com/statianzo/dokku-supervisord) and [dokku-persistent-storage](https://github.com/dyson/dokku-persistent-storage) as this plugin is really a combination of those two.

## License

This plugin is released under the MIT license. See the file [LICENSE](LICENSE).

[dokku]: https://github.com/progrium/dokku
[super]: http://supervisord.org
