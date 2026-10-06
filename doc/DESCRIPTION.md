The ArchiveTeam Warrior is a small "appliance" that volunteers your spare
bandwidth to the Internet Archive: it downloads snapshots of endangered
websites selected by the ArchiveTeam tracker and uploads them for long-term
preservation.

This package runs the official Warrior container under systemd. It is
outbound-only: no ports are opened and no router forwarding is needed. The
Warrior dashboard (queue status, project stats) is served behind YunoHost's
SSO and appears as a portal tile; the tracker nickname is taken from the
first YunoHost admin's fullname (purely cosmetic, no account required).
