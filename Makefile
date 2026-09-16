.PHONY: test lint

test:
	tests/lib/bashunit -j 8 tests/bashunit/palette_test.sh

lint:
	python3 -m py_compile palette.py open.py open_in_zed.py smart_close.py
	bash -n tests/bashunit/palette_test.sh tests/bashunit/test-dsl.bash tests/helpers/common.bash
