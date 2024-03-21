clean:
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)

build:
	docker build . -t lab1 \
	--build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" \
	--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" \

run: build
	sudo docker run -it --rm \
		-v ./scripts/output_repos/repos.json:/app/scripts/output_repos/repos.json \
		-v ./scripts/data_analysis/:/app/scripts/data_analysis/ \
		lab1
