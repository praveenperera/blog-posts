==title==
Complete Guide to Deploying Phoenix Applications using Dokku 0.4.0

==author==
Praveen Perera

==tags==
phoenix, dev-ops, tutorials

==description==
This is a complete guide on how to deploy a phoenix application to a VPS using Dokku 0.4.0. Dokku is built on docker and allows you to deploy apps using a heroku like workflow.

==body==
This is a complete guide on how to deploy a phoenix application to a VPS using Dokku 0.4.0. Dokku is built on docker and allows you to deploy apps using a heroku like workflow.

### Assumptions:

You are deploying to a fresh VM running Ubuntu 14.04 x64
Your VPS has at least 1GB of system memory [(workaround for 512MB machines)](https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04)

## Step 1: Installing dokku

**The commands in this section are run on the VPS**

First step is to [SSH](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets) into your VPS and then install dokku.

On your VPS run:

    $ apt-get update
    $ wget https://raw.github.com/progrium/dokku/v0.4.0/bootstrap.sh
    $ sudo DOKKU_TAG=v0.4.0 bash bootstrap.sh

Once it finishes, install the postgres plugin:

    $ dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres

## Step 2: Preparing your phoenix app

**The changes in this section are done on your local machine**

Now we need to make some changes to the application to get it production ready. First, lets commit `prod.secret.exs` to the git repo by commenting out the following line on the `.gitignore` file.

    #/config/prod.secret.exs

Next, open up the `prod.secret.exs` file and replace the secret key base with:

    secret_key_base: System.get_env("SECRET_KEY_BASE")

Next replace the username, password and database lines with:

    url: System.get_env("DATABASE_URL")

Your `prod.secret.exs` file should now look like this:

```elixir
use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :phoenix_dokku_example, PhoenixDokkuExample.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :phoenix_dokku_example, PhoenixDokkuExample.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20
```

Note: `:phoenix_dokku_example` and `PhoenixDokkuExample` would be replaced with your app name

Next, open up the `prod.exs` file and replace example.com with your domain name.

Now we need to tell dokku how to build the app. To do so, create a new file in the root of the phoenix application and name it `.buildpacks`. Inside this file, copy and paste the following lines:

    https://github.com/hashnuke/heroku-buildpack-elixir
    https://github.com/gjaldon/heroku-buildpack-phoenix-static

## Step 3: Deploying your APP using GIT

**The commands in this section are run on your local machine**

Dokku uses git hooks to deploy, so we need to go ahead and add your VPS as a git remote:

    $ git remote add dokku dokku@DOMAIN_NAME.com:APP_NAME

Note: change `DOMAIN_NAME.com` and `APP_NAME` to your domain name. Make sure both are the same, for example if you wanted to deploy to `http://awesomephoenix.com` the line above would look like this:

    $ git remote add dokku dokku@awesomephoenix.com:awesomephoenix.com

Now we need to create a user called dokku on the VPS:

    $ cat ~/.ssh/id_rsa.pub | ssh [sudouser]@[yourdomain].com "sudo sshcommand acl-add dokku [description]"

Note: replace `~/.ssh/id_rsa.pub` with the location to the public key you are using, and `[sudouser]`@`[yourdomain].com` with your root user and domain name respectively.

Finally you can deploy your application to your VPS:

    $ git push dokku master

## Step 4: Configure hostname and virtual host

**The commands in this section are run on the VPS**

Next we need to make sure that the VHOST and HOSTNAME are properly set up, to do so ssh back into your VPS and run the following commands:

    $ echo "DOMAIN_NAME.com" > /home/dokku/HOSTNAME
    $ echo "DOMAIN_NAME.com" > /home/dokku/VHOST
    $ dokku config:unset APP_NAME NO_VHOST
    $ dokku domains APP_NAME

NOTE: `DOMAIN_NAME.com` and `APP_NAME` must be the same, and to be clear it doesn't have to be a .com it can be any fully qualified domain name (FQDN) (.io, .org, .net etc...)

For example:

    $ echo "ilovephoenixframework.net" > /home/dokku/HOSTNAME
    $ echo "ilovephoenixframework.net" > /home/dokku/VHOST
    $ dokku config:unset ilovephoenixframework.net NO_VHOST
    $ dokku domains ilovephoenixframework.net

## Step 5: Configure database and environment variables

**The commands in this section are run on the VPS**

Now we need to set up some environment variables:

    $ dokku config:set APP_NAME MIX_ENV=prod
    $ dokku config:set APP_NAME PORT=5000

Next, create and link the postgres database with the app and run the migrations. Replace `DB_NAME` with whatever name you want to give the database:

    $ dokku postgres:create DB_NAME
    $ dokku postgres:link DB_NAME APP_NAME
    $ dokku run APP_NAME mix ecto.migrate

Now lets generate our application's secret key

    $ dokku run APP_NAME mix phoenix.gen.secret

This will print a string to your terminal window, this is `your secret key`, set it as an environment variable.

    $ dokku config:set APP_NAME SECRET_KEY_BASE=your_secret_key

Go to your website and your phoenix app should be up and running. Congrats!

Whenever you want to update your app all you have to do is commit the changes and push it your sever from your local machine by running:

    $ git push dokku master

### Useful Dokku Commands

You can also run dokku commands directly from your local machine. For example if you want to run a migration:

    $ ssh dokku@DOMAIN_NAME.com run APP_NAME mix ecto.migrate

You can set environment variables the same way:

     $ ssh dokku@DOMAIN_NAME.com config:set APP_NAME FOO=bar

### Resources

- [Deployed Phoenix Example App](https://github.com/praveenperera/phoenix-dokku-example){: target="\_blank" rel="noopener noreferrer"}
- [Dokku docs](http://progrium.viewdocs.io/dokku/installation/){: target="\_blank" rel="noopener noreferrer"}
- [Managing environment variables](http://progrium.viewdocs.io/dokku/configuration-management/){: target="\_blank" rel="noopener noreferrer"}
- [Customizing nginx and domains](https://progrium.viewdocs.io/dokku/nginx/){: target="\_blank" rel="noopener noreferrer"}
- [Postgresql plugin docs](https://github.com/dokku/dokku-postgres){: target="\_blank" rel="noopener noreferrer"}
