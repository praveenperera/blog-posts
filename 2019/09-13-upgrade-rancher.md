---
title: Backup and Upgrade Rancher
author: Praveen Perera
tags: dev-ops, digital-ocean, rancher, cheatsheet
description: In this tutorial I will be showing you how to backup and upgrade your version of rancher to the latest stable version
---

## Instructions

1. Setup the following script. We will fill it in going forward

```shell
RANCHER_CONTAINER_ID=
RANCHER_CONTAINER_TAG=
URL=rancher.yourdomain.com
TAG=stable

TIMESTAMP() {
  date +%Y-%m-%d_%H-%M-%S
}
```

2. SSH into your rancher droplet

```shell
ssh root@rancher.yourdomain.com
```

4. Get the `CONTAINER_ID` by running the command below, and fill it on the script from step 1

```shell
docker ps -a
```

```shell
RANCHER_CONTAINER_ID=1cb2c853937b
RANCHER_CONTAINER_TAG=
URL=rancher.yourdomain.com
TAG=stable

TIMESTAMP() {
  date +%Y-%m-%d_%H-%M-%S
}
```

4. Go to your installation of rancher at `rancher.yourdomain.com` and find
   the rancher version on the bottom left of the screen. Fill this into the script
   from step 1.

```shell
RANCHER_CONTAINER_ID=1cb2c853937b
RANCHER_CONTAINER_TAG=v2.2.4
URL=rancher.yourdomain.com
TAG=stable

TIMESTAMP() {
  date +%Y-%m-%d_%H-%M-%S
}
```

5. Go back to your droplet and paste the script we've been building

6. Stop the container currently running rancher

```shell
docker stop $RANCHER_CONTAINER_ID
```

7. Pull the latest stable version of rancher

```shell
docker pull rancher/rancher:$TAG
```

8. Create a volume from the rancher container. If you've already done this during
   a earlier upgrade or backup you can skip this step.

```shell
docker create --volumes-from $RANCHER_CONTAINER_ID \
--name rancher-data rancher/rancher:$RANCHER_CONTAINER_TAG
```

9. Create a backup of your rancher volume into a single file

```shell
docker run --volumes-from rancher-data  -v $PWD:/backup alpine tar zcvf /backup/rancher-data-backup-$RANCHER_CONTAINER_TAG-$(TIMESTAMP).tar.gz /var/lib/rancher
```

10. Confirm that a new backup files exists with the container tag and timestamp

11. Start the new version of rancher

```shell
docker run -d --volumes-from rancher-data  \
              --restart=unless-stopped -p 80:80 -p 443:443  \
              rancher/rancher:$TAG --acme-domain $URL
```

12. Go back into your rancher instance, log back in and confirm that you are running
    the latest stable version

13. Remove the old stopped rancher container

```shell
docker rm $RANCHER_CONTAINER_ID
```

## Screencast

<iframe title="embedded youtube video walkthrough" width="560" height="315" src="https://www.youtube.com/embed/LuY0zB1QjtI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Resources

- [Single Node Upgrade](https://rancher.com/docs/rancher/v2.x/en/upgrades/upgrades/single-node-upgrade/)
- [Creating Backups—Single Node Installs](https://rancher.com/docs/rancher/v2.x/en/backups/backups/single-node-backups/)
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
