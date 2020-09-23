# Devenv for Dataconnect

The goal of this repository is to provide a dockerized environment for the dataconnect project for development and tests. 

It provides two docker containers

## Datashare devenv

it contains :

- nodejs environment for the frontend
- java JDK and maven for the backend
- ansible to deploy
- ssh agent mapped
- docker env mapped

We suppose that the project home is located in `machines/dataconnect`.

## Discourse devenv 

it is based on the [discourse devenv](https://github.com/discourse/discourse_docker)

it contains : 

- ruby tools (bundle, rake, RoR, ...) 
- ssh agent mapped
- docker env mapped

# How to use it

## Creating datashare devenv docker image locally

You only have to do this once to create the devenv image locally in you docker registry. Next time you want to use it you can go to the next section. 
What I did : 

```shell script
mkdir -p machines/dataconnect/src # or another path as you prefer
cd machines/dataconnect/src
git clone git@github.com:ICIJ/datashare-devenv.git
cd datashare-devenv
git fetch origin dataconnect
git co dataconnect
docker build -t dsenv .
# wait for the image to build for a while
```

## Launching and entering into the images

Every dev application (for ex IDE) that you want to use inside the container
AND outside should be located in `~/Applications` : this folder will be mounted inside 
with the same name.

You have also to be logged in with dockerhub (icij and public one) to be able to pull the images.

To log in the ICIJ registry : 

```shell script
docker login -u icij_registry registry.cloud.icij.org
```

To enter in discourse devenv
```shell script
# in machines/dataconnect
DSENV_CONTAINER=discourse_dev ./src/datashare-devenv/dsenv.sh enter
# then you must be in the discourse development environment
cd src
git clone git@github.com:ICIJ/icij-discourse
git clone git@github.com:ICIJ/datashare-client.git
git clone git@github.com:ICIJ/datashare.git
...
```

To enter in datashare devenv

```shell script
# in machines/dataconnect
./src/datashare-devenv/dsenv.sh enter
# then you must be in the datashare development environment
```

To stop the devenv
```shell script
# inside the container
$ exit
# then you should be in machines/dataconnect outside the docker container
./src/datashare-devenv/dsenv.sh stop
```

# Running services inside docker

## Running discourse

```shell script
cd src/icij-discourse
git submodule update --init --recursive # to get the plugins
bundle install
rails db:migrate
rails s -b 0.0.0.0
```
discourse is now accessible at `localhost:3000`

## Running datashare

```shell script
cd src/datashare-client
yarn
make clean dist
cd ../datashare
# bootstrapping database and front
mvn validate
mvn -pl commons-test -am install
mvn -pl datashare-db liquibase:update
ln -s ../datashare-client app
# then to compile
make clean dist
./launchBack
```
datashare is now accessible at `localhost:8888`
