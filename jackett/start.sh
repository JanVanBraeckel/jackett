#!/bin/bash

if [[ ! -e /config/Jackett ]]; then
	mkdir -p /config/Jackett
	chown -R ${PUID}:${PGID} /config/Jackett
else
	chown -R ${PUID}:${PGID} /config/Jackett
fi

## Check for missing group
/bin/egrep  -i "^${PGID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "Group $PGID exists"
else
   echo "Adding $PGID group"
	 groupadd -g $PGID jackett
fi

## Check for missing userid
/bin/egrep  -i "^${PUID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "User $PUID exists in /etc/passwd"
else
   echo "Adding $PUID user"
	 useradd -c "jackett user" -g $PGID -u $PUID jackett
fi

# set umask
export UMASK=$(echo "${UMASK}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${UMASK}" ]]; then
  echo "[info] UMASK defined as '${UMASK}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] UMASK not defined (via -e UMASK), defaulting to '002'" | ts '%Y-%m-%d %H:%M:%.S'
  export UMASK="002"
fi

echo "[info] Starting jackett daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/jackett/jackett.init start &
chmod -R 755 /config/Jackett

sleep 1
jpid=$(pgrep -o -x jackett)
echo "[info] jackett PID: $jpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$jpid ]; then
	if [[ -e /config/Jackett/logs/jackett-daemon.log ]]; then
		chmod 775 /config/Jackett/logs/jackett-daemon.log
	fi
	sleep infinity
else
	echo "jackett failed to start!"
fi
