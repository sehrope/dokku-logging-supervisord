.PHONY: test test-default test-run-filter

test: test-default test-run-filter

test-default:
	@echo testing defaults
	@$(QUIET) [[ `bash lib/procfile-to-supervisord Procfile SCALE | grep "\[progra" | wc -l` -eq 4 ]] || exit 1
	@echo test succeeded

test-run-filter:
	@echo testing DOKKU_SUPERVISOR_RUN
	@$(QUIET) [[ `unset DOKKU_SUPERVISOR_RUN; DOKKU_SUPERVISOR_RUN="web lowlatencyworker" bash lib/procfile-to-supervisord Procfile SCALE | grep "\[progra" | wc -l` -eq 2 ]] || exit 1
	@echo test succeeded
