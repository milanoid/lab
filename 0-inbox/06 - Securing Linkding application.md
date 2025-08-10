### Exercise

Here's a challenge. Our pod is currently running as root.

- This is super dangerous! We want to avoid this at all times.
- Configure the deployment to run as a non-root user. And the container should not be able to escalate privileges.
- Do you know how to figure out which user the application is running as?

----

The user runnign the Linkding app is `www-data`

```bash
root@linkding-54d55c59cb-cfngb:/etc/linkding# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
www-data       1  0.0  0.7  61088 54716 ?        Ss   Aug08   0:20 uwsgi --http :9090 uwsgi.ini
root          18  0.0  0.2  33080 21660 ?        Ss   Aug08   0:53 /opt/venv/bin/python /opt/venv/bin/supervisord -c supervis
www-data      19  0.0  0.9 193148 67916 ?        Sl   Aug08   0:00 uwsgi --http :9090 uwsgi.ini
www-data      21  0.0  0.9 193176 68300 ?        Sl   Aug08   0:00 uwsgi --http :9090 uwsgi.ini
www-data      23  0.0  0.6  69284 51404 ?        S    Aug08   0:00 uwsgi --http :9090 uwsgi.ini
www-data      24  0.2  0.9 337964 72112 ?        Sl   Aug08   5:47 python manage.py run_huey -f
root          28  0.0  0.0   4608  3712 pts/0    Ss   14:52   0:00 bash
root        6229  100  0.0   8540  4352 pts/0    R+   15:00   0:00 ps aux
```

