# Devenv for Datashare

The goal of this repository is to provide a dockerized environment for [datashare](https://github.com/ICIJ/datashare) development and tests. 

It provides a docker container with :

- nodejs environment for the frontend
- java JDK and maven for the backend
- ansible to deploy
- ssh agent mapped
- docker env mapped

# How to use it

## Develop

You can build your dev container running in this repository :
```
1-$ docker build -t dsenv .
2-$ docker login
# go where you want to set your development home
3-$ path/to/datashare-devenv/dsenv.sh enter
# ... dev session inside the container
# then exit 
4-$ path/to/datashare-devenv/dsenv.sh stop
```

1. is going to build a dsenv container locally.
2. is going to log in into Docker Hub to download images (postgresql).
3. is starting the datashare containers with the docker-compose.yml file and entering inside it (docker exec -ti ...)
4. is stopping all the datashare containers

Then after having built the dsenv container you just have to make a `dsenv.sh enter`.

## Testing locally with latest sources

To use the whole stack (with xemx logging) you can:

1. connect xemx on http://xemx:3001 *into the container* (so you can lauch a firefox inside the container)
2. define a datashare application with the return url http://dsenv:8080/auth/xemx/callback
3. make a link between the back and the front : in the datashare source folder `ln -s ../datashare-client/dist app` (you have to have compiled a front dist before)
3. launch the backend with `./launchBack.sh -m SERVER --oauthClientId <yourid> --oauthClientSecret <your_secret>`
4. connect datashare *into the container* on http://dsenv:8080
5. logon datashare with dev/dev

## Comon pitfalls

If you are still using old DNS, you'll have to set the DNS server via an environment variable:

```
DS_DNS=172.30.0.2 path/to/datashare-devenv/dsenv.sh start
```


If you run docker via sudo you'll have to pass SSH_AUTH_SOCK variable, run the script this way:

```
sudo SSH_AUTH_SOCK=${SSH_AUTH_SOCK} ./dsenv.sh start
```
