data_path := ~/.local/share/nvim

.PHONY: init
init:
	$(MAKE) init_auto_session

.PHONY: init_auto_session
init_auto_session:
	mkdir -p $(data_path)/sessions
