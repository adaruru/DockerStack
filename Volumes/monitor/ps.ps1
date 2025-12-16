function buildMonotor{
    createAndUse63
    cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\monitor
    docker compose up -d --pull always prometheus
    docker compose up -d --pull always grafana
    docker compose up -d --pull always alertmanager
    docker compose up -d --pull always node_exporter
    docker compose up -d --pull always cadvisor
}