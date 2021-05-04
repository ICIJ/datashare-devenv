# ICIJ's Devenv

The goal of this repository is to provide a dockerized environment for ICIJ products.

That includes:

* A `workspace` service to build and run Datashare:
  * Nodejs environment for the frontend
  * Java JDK and maven for the backend
  * Ansible to deploy
  * SSH agent mapped
  * Docker env mapped
* A `discourse` service to run [ICIJ's Discourse instance](https://github.com/icij/icij-discourse) (also known as iHub):
  * Ruby tools (bundle, rake, RoR, ...)
  * SSH agent mapped
  * Docker env mapped
* A `xemx` service to run ICIJ's Singl-Sign-On ;
* An `openldap` service to provide users directory to `xemx` ;

# How to use it

## First Start

Every dev application (for ex IDE) that you want to use inside the container
AND outside should be located in `~/Applications`: this folder will be mounted
inside the `workspace` service with the same name.

You must also be logged in with ICIJ Docker regsitry to be able to pull the images.

To log in :

```shell script
docker login registry.cloud.icij.org -u icij_registry
```

This will prompt your for the password which is saved in `pass`:

```shell script
pass show registry.cloud.icij.org/icij_registry
```

You only have to do this once to create the devenv image locally.

```shell script
mkdir -p ~/src # or another path as you prefer
cd ~/src
git clone git@github.com:ICIJ/datashare-devenv.git
cd datashare-devenv
# This will build the dsenv image. This might take a while.
./build.sh
```

## Entering `workspace` service

To enter in ICIJ's workspace service:

```shell script
./src/datashare-devenv/dsenv.sh enter
```

To build Datashare Frontend:

```shell script
cd src
git clone git@github.com:ICIJ/datashare-client
cd datashare-client
yarn
yarn build
```

To build Datashare Backend:

```shell script
cd src
git clone git@github.com:ICIJ/datashare
cd datashare
# bootstrapping database and front
mvn validate
mvn -pl commons-test -am install
mvn -pl datashare-db liquibase:update
# copy the compiled frontend
ln -s ../datashare-client/dist app
# then to compile
make clean dist
./launchBack
```

Datashare is now accessible at `localhost:8888`

## Entering `discourse` service

To enter in ICIJ's Discourse service:

```shell script
./src/datashare-devenv/dsenv.sh enter discourse
```

Since the homedir is overridden by your, you must clone ICIJ's Discourse
repository:

```shell script
cd src
git clone git@github.com:ICIJ/icij-discourse
```

Then install and run Discourse:

```shell script
cd src/icij-discourse
git submodule update --init --recursive # to get the plugins
bundle install
rails db:migrate
rails s -b 0.0.0.0
```

The service is now accessible at `localhost:3000`

## Common pitfalls

If you run docker via sudo you'll have to pass SSH_AUTH_SOCK variable, run the script this way:

```
sudo SSH_AUTH_SOCK=${SSH_AUTH_SOCK} ./dsenv.sh enter
