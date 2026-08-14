deploy:
    git push 
    cd ../static_sites && just deploy blog
