function buildIts{
    createAndUse63
    cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\its
    docker compose up -d --pull always docker-registry
    docker compose up -d --pull always registry-ui
    docker compose up -d --pull always its-certcenter
}