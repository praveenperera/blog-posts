# Blog posts

This repository contains the posts and static assets for
[praveenperera.com](https://praveenperera.com).

## Deploy the blog

The deployment uses the `static_sites` repository in the parent directory.
Install its dependencies and authenticate Wrangler with Cloudflare before the
first deployment.

Commit and push the blog changes before deployment. The deploy command fetches
the current branch from `origin` and does not include local or unpushed changes.

```sh
git push origin "$(git branch --show-current)"
cd ../static_sites
just deploy blog
```

The command builds the Astro site and deploys it to Cloudflare Workers. After
it completes, check the changed page at
[praveenperera.com/blog](https://praveenperera.com/blog/).

## Preview local changes

The development server reads the local `blog-posts` working tree. A commit or
push is not required for a preview.

```sh
cd ../static_sites
just dev blog
```
