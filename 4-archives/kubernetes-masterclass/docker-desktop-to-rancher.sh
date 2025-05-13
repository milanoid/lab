# Replace the symlink for docker-buildx - will be overridden once Docker Desktop starts
rm ~/.docker/cli-plugins/docker-buildx
ln -s ~/.rd/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
ls -l ~/.docker/cli-plugins/docker-buildx

# Replace the symlink for docker-compose
rm ~/.docker/cli-plugins/docker-compose
ln -s ~/.rd/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ls -l ~/.docker/cli-plugins/docker-compose
