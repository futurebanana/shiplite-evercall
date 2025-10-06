GITHUB_TOKEN ?=
GITHUB_REPOSITORY ?=

.PHONY: build
build:
	docker build -t karstenjakobsen/shiplite-evercall-runner:latest .

.PHONY: run
run:
	docker run -it --rm \
	-e REPOSITORY=${GITHUB_REPOSITORY} -e ACCESS_TOKEN=${GITHUB_TOKEN} \
	-e RUNNER_NAME="runner-$(shell date +%s)" -e RUNNER_LABELS="self-hosted,Linux,X64,custom" \
	karstenjakobsen/shiplite-evercall-runner:latest .
