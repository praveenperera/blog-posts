==title==
Using LetsEncrypt to Switch a Phoenix App Deployed with Dokku to HTTPS

==author==
Praveen Perera

==tags==
phoenix, dev-ops, tutorials, elixir

==description==
Do you have a Phoenix application deployed using Dokku? Then you have can switch to using HTTPS in less than 5 minutes.

==body==
Do you have a [Phoenix application deployed using Dokku](deploying-phoenix-applications-using-dokku/)? Then you have can switch to using HTTPS in less than 5 minutes.

This is more of a Dokku post because this same process will probably work with any other application deployed with it. I've encrypted two Phoenix apps and this ghost blog using the same process.

Requirements: Dokku 0.4 or above

## Instructions

1. SSH into your VM and install the [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt){: target="\_blank" rel="noopener noreferrer"} plugin: `sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git`

2. Set up LetsEncrypt with your email:
   `dokku letsencrypt:email myapp your@email.tld`

3. Set Up SSL:
   `dokku letsencrypt myapp`

And thats it! Your container will restart and now your using HTTPS, how easy was that!
