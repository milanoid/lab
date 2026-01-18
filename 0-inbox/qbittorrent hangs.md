### symptoms

Recently I started to use the `qbittorrent` client more. The files were not downloaded as expected. I could not open the web UI running at port 8080 while the Pod itself was in running state. I could also open shell of the container and run some commands.

```bash
# the applicaion `qbittorrent` was running
root@torrent-client-7b57cd6485-26mlk:/# ps ax | grep qbittorrent
     39 ?        S      0:00 s6-supervise svc-qbittorrent
    291 ?        Ssl    1:58 /usr/bin/qbittorrent-nox --webui-port=8080 --torrenting-port=6881
    643 pts/1    S+     0:00 grep qbittorrent
    
# the webUI was not reachable
wget http://localhost:8080
Connection refused
```

### observations

1. app log - issues with permissions

```bash
kubectl logs pods/torrent-client-7b57cd6485-26mlk

...
chown: changing ownership of '/config/qBittorrent/.DS_Store': Operation not permitted                                                                        ...

```

```bash
# disable macOS to create .DS_Store on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
```