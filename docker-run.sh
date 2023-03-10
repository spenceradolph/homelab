docker network create private

docker volume create proxymanager_data
docker volume create proxymanager_letsencrypt
docker volume create pihole_etc
docker volume create pihole_dnsmasq
docker volume create portainer_data
docker volume create heimdall_data
docker volume create homeassistant_data
docker volume create gitlab_etc
docker volume create gitlab_log
docker volume create gitlab_opt
docker volume create gitlab_runner_config

docker run -d --name cloudflare-tunnel --net private --restart=unless-stopped cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoiYWNhMzIzMjc1YTdhYzEwMjQ1MWFhNWY1OWM1YTg5MDUiLCJ0IjoiYjI3ZTJmODQtYmFlNS00MTViLThhYmYtYmMzYjNmY2VmOGQ1IiwicyI6Ik1UbGhaalEzT1RrdFptUmxPUzAwT0RZMkxXSmhaamN0TURNMFpEVTBNakU0WlRNeiJ9
docker run -d --name npm -p 80:80 -p 443:443 --restart=unless-stopped --net private -v npm_data:/data -v npm_letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager
docker run -d --name pihole -p 53:53/tcp -p 53:53/udp --net private -e TZ="America/Chicago" -e WEBPASSWORD=password -v pihole_etc:/etc/pihole -v pihole_dnsmasq:/etc/dnsmasq.d --dns=127.0.0.1 --dns=1.1.1.1 --restart=unless-stopped pihole/pihole
docker run -d --name portainer --restart=always --net private -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
docker run -d --restart=always --net private --name=heimdall -e TZ=America/Chicago -v heimdall_data:/config linuxserver/heimdall
docker run -d --restart=unless-stopped --name homeassistant -e TZ="America/Chicago" --net private -v homeassistant_data:/config homeassistant/home-assistant
docker run -d --restart=unless-stopped --name gitlab --net private --hostname gitlab.adolph.io --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.adolph.io/;'" gitlab/gitlab-ce
docker run -d --name gitlab-runner --net private --restart always -v /var/run/docker.sock:/var/run/docker.sock -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest

# get gitlab password
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

# for gitlab runner config (once gitlab is healthy, ready to join it)
docker run --rm -it --net private -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest register