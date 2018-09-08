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

Then after having built the dsenv container you just have to make a `dsenv.sh start` and `enter_dsenv.sh.

To use the whole stack (with xemx logging) you can:

1. connect xemx on http://xemx:3001 *into the container* (so you can lauch a firefox inside the container)
2. define a datashare application with the return url http://dsenv:8080/auth/xemx/callback
3. launch the backend with `./launchBack.sh -w -m PRODUCTION --oauthClientId <yourid> --oauthClientSecret <your_secret>`
4. connect datashare *into the container* on http://dsenv:8080
5. logon datashare with dev/dev


