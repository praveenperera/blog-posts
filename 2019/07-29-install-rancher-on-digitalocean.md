==title==
Install Rancher on DigitalOcean

==updated_at==
2020-08-07

==author==
Praveen Perera

==tags==
dev-ops, digital-ocean, rancher, cheatsheet, rancher-on-doks

==description==
A tutorial showing you how to install Rancher on DigitalOcean

==body==

## Instructions

1. Start by creating a brand new droplet on DigitalOcean. Create a droplet with **4GB
   of RAM**. Make sure you select **Ubuntu 18.09 (LTS)**.
2. SSH into the droplet to install Docker
3. Install rancher

```shell
curl https://releases.rancher.com/install-docker/19.03.sh | sh
```

4. Point your DNS records for rancher.\$DOMAIN.com to your rancher droplets IP

   - Its a good idea to use a floating IP for your rancher droplet

5. Install and start rancher

```shell
docker run -d --restart=unless-stopped \
              -p 80:80 -p 443:443 rancher/rancher:stable \
              --acme-domain rancher.$DOMAIN.com
```

6. Go to `rancher.$DOMAIN.com` and set up a new password

## Screencast

<iframe title="embedded youtube video walkthrough" width="560" height="315" src="https://www.youtube.com/embed/tiSUpKDgWfQ" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Resources

- [Install Docker Script](https://rancher.com/docs/rancher/v2.x/en/installation/requirements/installing-docker/)
- [Rancher Node Requirements](https://rancher.com/docs/rancher/v2.x/en/installation/requirements/)
- [Install Docker Community Edition](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [Rancher Single Node Install](https://rancher.com/docs/rancher/v2.x/en/installation/single-node/)
- [DigitalOcean Referal Link](https://m.do.co/c/f8176c37fe0d)

## Get More!

<br>
<!-- Begin Mailchimp Signup Form -->
<link href="//cdn-images.mailchimp.com/embedcode/horizontal-slim-10_7.css" rel="stylesheet" type="text/css">
<style type="text/css">
	#mc_embed_signup{background:#fff; clear:left; font:14px Helvetica,Arial,sans-serif; width:100%;}
	/* Add your own Mailchimp form style overrides in your site stylesheet or in this style block.
	   We recommend moving this block and the preceding CSS link to the HEAD of your HTML file. */
</style>
<div id="mc_embed_signup">
<form action="https://avencera.us3.list-manage.com/subscribe/post?u=687ec560e21ef5d40d8d1cf9b&amp;id=4e8e7b9bdb" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" class="validate" target="_blank" novalidate>
    <div id="mc_embed_signup_scroll">
	<label for="mce-EMAIL">Get Notified of More Rancher Tutorials</label>
	<input type="email" value="" name="EMAIL" class="email" id="mce-EMAIL" placeholder="email address" required>
    <!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
    <div style="position: absolute; left: -5000px;" aria-hidden="true"><input type="text" name="b_687ec560e21ef5d40d8d1cf9b_4e8e7b9bdb" tabindex="-1" value=""></div>
    <div class="clear"><input type="submit" value="Subscribe" name="subscribe" id="mc-embedded-subscribe" class="button"></div>
    </div>
</form>
</div>
<!--End mc_embed_signup-->
<br>
