==title==
Provision DigitalOcean Loadbalancer with NGINX Ingress Controller for Kubernetes

==author==
Praveen Perera

==tags==
kubernetes, cheatsheet, dev-ops, digital-ocean, rancher, rancher-on-doks

==description==
In this tutorial I will show you how to provision a loadbalancer
DigitalOcean managed Kubernetes cluster

==updated_at==
2020-05-14

==body==

## Instructions

1. Once you have kubectl setup make sure you are in the correct context.

```shell
kubectl config current-context
```

2. Create the ingress controller loadbalancer service. This will automatically create the DigitalOcean loadbalancer.

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/do/deploy.yaml
```

3. Go to your DigitalOcean account and make sure the loadbalancer has been provisioned and is healthy.

## Screencast

<iframe title="embedded youtube video walkthrough" width="560" height="315" src="https://www.youtube.com/embed/wvQAAtDfGfg" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Resources

- [How to Set Up an Nginx Ingress with Cert-Manager on DigitalOcean Kubernetes](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes#step-2-—-setting-up-the-kubernetes-nginx-ingress-controller)

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
