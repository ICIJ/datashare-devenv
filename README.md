# Devenv for Datashare

The goal of this repository is to provide a dockerized environment for [datashare](https://github.com/ICIJ/datashare) development. 

It provides a docker container with :

- nodejs environment for the frontend
- java JDK and maven for the backend
- ansible to deploy
- ssh agent mapped
- docker env mapped

# How to use it

You can build your dev container running in this repository :

```
1-$ docker build -t dsenv .
# go where you want to set your development home
2-$ path/to/datashare-devenv/dsenv.sh start
3-$ path/to/datashare-devenv/enter_dsenv.sh
# ... dev session inside the container
# then exit 
4-$ path/to/datashare-devenv/dsenv.sh stop
```

1. is going to build a dsenv container locally.
2. is starting the datashare containers with the docker-compose.yml file
3. is entering inside the container (docker exec -ti ...)
4. is stopping all the datashare containers
