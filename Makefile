.PHONY: test test-default test-run-filter

PROCFILE_PATH := "/tmp/Procfile"
SCALE_FILE_PATH := "/tmp/SCALE"

test: test-default test-run-filter

test-default:
	@$(MAKE) setup-procfile setup-scale-file
	@echo testing defaults
	@$(QUIET) [[ `bash lib/procfile-to-supervisord $(PROCFILE_PATH) $(SCALE_FILE_PATH) | grep "\[progra" | wc -l` -eq 4 ]] || exit 1
	@echo test succeeded
	@$(MAKE) clean

test-run-filter:
	@$(MAKE) setup-procfile setup-scale-file
	@echo testing DOKKU_SUPERVISOR_RUN
	@$(QUIET) [[ `unset DOKKU_SUPERVISOR_RUN; DOKKU_SUPERVISOR_RUN="web lowlatencyworker" bash lib/procfile-to-supervisord $(PROCFILE_PATH) $(SCALE_FILE_PATH) | grep "\[progra" | wc -l` -eq 2 ]] || exit 1
	@echo test succeeded
	@$(MAKE) clean

setup-procfile:
	@echo "web: run webserver" > $(PROCFILE_PATH)
	@echo "assets: build assets" >> $(PROCFILE_PATH)
	@echo "db-migrate: migrate db" >> $(PROCFILE_PATH)
	@echo "urgentworker: run urgentworker" >> $(PROCFILE_PATH)
	@echo "worker: run worker" >> $(PROCFILE_PATH)
	@echo "lowlatencyworker: run lowlatencyworker" >> $(PROCFILE_PATH)

setup-scale-file:
	@echo "web=1" > $(SCALE_FILE_PATH)
	@echo "worker=1" >> $(SCALE_FILE_PATH)
	@echo "urgentworker=1" >> $(SCALE_FILE_PATH)
	@echo "assets=0" >> $(SCALE_FILE_PATH)
	@echo "db-migrate=0" >> $(SCALE_FILE_PATH)

clean:
	@$(QUIET) rm -f $(PROCFILE_PATH) $(SCALE_FILE_PATH)
