---
title: Install and Setup Cert-Manager for Automated SSL Certificates
author: Praveen Perera
tags: kubernetes, cheatsheet, dev-ops, digital-ocean, rancher, rancher-on-doks
description: In this tutorial I will show you how to install cert-manager to your Kubernetes cluster
twitter:
  image: https://praveenperera.com/images/posts/install_cert_manager.jpg
  card: summary_large_image
---

## Instructions

1. Create the `cert-manager` namespace by going into your terminal and using kubectl.

```bash
kubectl create namespace cert-manager
```

2. Add the following label to the namespace.

```bash
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
```

3. Install cert-manager and the necessary CustomResourceDefinitions.

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.10.0/cert-manager.yaml
```

4. Go into your rancher install and add the `cert-manager` namespace into the `System` project.

5. Create the cluster issuer.
   - See an example one using the cloudflare DNS challenge below
   - To see an example one for AWS Route53, [click here](https://gist.github.com/praveenperera/8c9faee270d133035cab33ae67ab56c1)

```yaml
# prod_issuer.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: your_email@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - selector: {}
        dns01:
          cloudflare:
            email: cloudflare_email@gmail.com
            apiKeySecretRef:
              name: cloudflare_api_key_secret
              key: api-key
```

6. Go into rancher `System` project, `Resources` and click `Secrets`.

7. Add a secret that matches the yaml file from step 5.

```
name = cloudflare-api-key-secret
key = api-key
value = YOUR_API_TOKEN_FROM_CLOUDFLARE
```

8. Select `Available to a single namespace`, select the `cert-manager` namespace and click `Save`

9. Go back into your terminal and create the cluster issuer using the template from step 5

```shell
kubectl create --namespace=cert-manager -f prod_issuer.yaml
```

10. Create the yaml file to get your SSL certificate

```yaml
# certificate.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: yourwebsite.com
  namespace: main
spec:
  secretName: yourwebsite-com-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: "*.yourwebsite.com"
  dnsNames:
    - yourwebsite.com
    - "*.yourwebsite.com"
```

11. Create the certificate using the yaml file from before

```shell
kubectl create --namespace=main -f certificate.yaml
```

12. Other useful commands

```bash
kubectl get certificate
kubectl describe certificate yourwebsite-com-tls

kubectl describe order yourwebsite-com-tls630199403 -n main

kubectl get secret
kubectl describe secret yourwebsite-com-tls

```

## Screencast

<iframe title="embedded youtube video walkthrough" width="560" height="315" src="https://www.youtube.com/embed/ANAqRbXINHg" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Resources

- [Cert Manager - Installing on Kubernetes](https://docs.cert-manager.io/en/latest/getting-started/install/kubernetes.html)

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
