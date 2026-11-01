# Yarr LazyCat community package

Upstream https://github.com/nkanaev/yarr (MIT), v2.9. Package `community.lazycat.app.yarr`, min OS 1.5.0, amd64, mirror delivery, community (喵喵) store only.

Single Go binary with an embedded SQLite database — no external services. The image already defaults to `-addr 0.0.0.0:7070 -db /data/yarr.db`, so one bind carries all state:

    /lzcapp/var/data:/data

**Authentication is forced.** Yarr serves everything to anyone who can reach its port unless `--auth-file` is given. `content/start.sh` therefore refuses to start without deployment credentials, rejects a colon in either half (Yarr splits the auth line on the first colon), renders `/run/yarr/auth` on tmpfs with mode 600, and execs Yarr with `-auth-file`. The credential never ships in the package and never lands in the data volume.

The app still sits behind the LazyCat entry login; no `public_path` is declared.

Not device-tested: login, subscribing, OPML import/export, read-state, and persistence across restarts.
