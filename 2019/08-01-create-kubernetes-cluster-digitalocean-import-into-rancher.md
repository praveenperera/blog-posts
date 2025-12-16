==title==
Create a Kubernetes Cluster on DigitalOcean and Import into Rancher

==author==
Praveen Perera

==tags==
kubernetes, cheatsheet, dev-ops, digital-ocean, rancher, rancher-on-doks

==description==
In this tutorial I will be showing you how to create Kubernetes
(K8s) cluster on DigitalOcean managed kubernetes (DOKS). Then I will show you
to import it into Rancher

==body==

## Instructions

1. Create kubernetes cluster on DigitalOcean
2. Install `doctl` DigitalOcean CLI tool

```shell
brew install doctl
```

3. Install `kubectl` command line tool for kubernetes

```shell
brew install kubectl
```

4. Get a list of your DigitalOcean kubernetes clusters

```shell
doctl kubernetes cluster list
```

5. Save the kubernetes .kubeconfig file using doctl

```shell
doctl kubernetes cluster kubeconfig save $cluster_name
```

6. Go to your rancher install
7. Click `Add Cluster`, select `Import` under Import Existing Cluster and click `Create`
8. Copy the kubectl command given to you in the next screen and paste into your terminal

## Screencast

<iframe title="embedded youtube video walkthrough" width="560" height="315" src="https://www.youtube.com/embed/PlFdjhVOt98" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Resources

- [doctl](https://github.com/digitalocean/doctl)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Importing Kubernetes Clusters to Rancher](https://rancher.com/docs/rancher/v2.x/en/cluster-provisioning/imported-clusters/)
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
