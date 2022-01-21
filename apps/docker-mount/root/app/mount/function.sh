#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE      #
# NO CUSTOMIZING IS ALLOWED         #
# NO REBRANDING IS ALLOWED          #
# NO CODE MIRRORING IS ALLOWED      #
#####################################
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006
## FUNCTIONS SOURCECONFIG ##
#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################

source /system/mount/mount.env

#SETTINGS
CONFIG=/app/rclone/rclone.conf
ENVA=/system/mount/mount.env
TMPENV=/tmp/mount.env
GDSAMIN=4
ARRAY=$(ls -A ${JSONDIR} | wc -l )

#SCRIPTS
SROTATE=/app/mount/rotation.sh
SCRIPT=/app/mount/mount.sh
SDISCORD=/app/discord/discord.sh

#FOLDER
REMOTE=/mnt/unionfs
JSONDIR=/system/mount/keys
SMOUNT=/app/mount
FDISCORD=/app/discord
LFOLDER=/app/language/mount

#LOG
MLOG=/system/mount/logs/rclone-union.log
RLOG=/system/mount/logs/vfs-refresh.log
DLOG=/tmp/discord.dead

#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################

function log() {

   echo "[Mount] ${1}"

}

function run() {

   bash "${1}"

}

function checkban() {

   tail -n 1 "${MLOG}" | grep --line-buffered 'googleapi: Error' | while read; do
       if [[ ! ${DISCORD_SEND} != "null" ]]; then
          discord
       else
          log "${startuphitlimit}"
       fi

       if [[ ${ARRAY} != 0 ]]; then
          run "${SROTATE}"
          log "${startuprotate}" 
       fi
   done

}

function discord() {

   source /system/mount/mount.env
   DATE=$(date "+%Y-%m-%d")
   YEAR=$(date "+%Y")

   if [[ ${ARRAY} -gt 0 ]]; then
      MSG1=${startuphitlimit}
      MSG2=${startuprotate}
      MSGSEND="${MSG1} and ${MSG2}"
      rm -rf ${DLOG}
   else
      MSG1=${startuphitlimit}
      MSGSEND="${MSG1}"
   fi

   if [[ ! -d "${FDISCORD}" ]]; then
      mkdir -p "${FDISCORD}"
   fi

   if [[ ! -f "${SDISCORD}" ]]; then
      curl --silent -fsSL https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh -o "${SDISCORD}"
      chmod 755 "${SDISCORD}"
   fi

   if [[ ! -f "${DLOG}" ]]; then
      run "${SDISCORD}" \
      --webhook-url=${DISCORD_WEBHOOK_URL} \
      --title "${DISCORD_EMBED_TITEL}" \
      --avatar "${DISCORD_ICON_OVERRIDE}" \
      --author "Dockerserver.io Bot" \
      --author-url "https://dockserver.io/" \
      --author-icon "https://dockserver.io/img/favicon.png" \
      --username "${DISCORD_NAME_OVERRIDE}" \
      --description "${MSGSEND}" \
      --thumbnail "https://www.freeiconspng.com/uploads/error-icon-4.png" \
      --footer "(c) ${YEAR} DockServer.io" \
      --footer-icon "https://www.freeiconspng.com/uploads/error-icon-4.png" \
      --timestamp > "${DLOG}"
   fi

}

function envrenew() {

   diff -q "$ENVA" "$TMPENV"
   if [ $? -gt 0 ]; then
      rckill && run "${SCRIPT}"
    else
      echo "no changes" > "${NLOG}"
   fi

}

function lang() {

   LANGUAGE=${LANGUAGE}
   startupmount=$(grep -Po '"startup.mount": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuphitlimit=$(grep -Po '"startup.hitlimit": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuprotate=$(grep -Po '"startup.rotate": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startupnewchanges=$(grep -Po '"startup.newchanges": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuprcloneworks=$(grep -Po '"startup.rcloneworks": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   currenttime=$(date +%H:%M)

   if [[ "$currenttime" > "23:59" ]] || [[ "$currenttime" < "00:01" ]]; then
      if [[ -d "/app/language" ]]; then
         git -C "${LFOLDER}/" stash --quiet
         git -C "${LFOLDER}/" pull --quiet
         cd "${LFOLDER}/"
         git stash clear
      fi
   fi

   if [[ ! -d "/app/language" ]]; then
      mkdir -p "${LFOLDER}/"
      git -C /app clone https://github.com/dockserver/language.git
   fi

}

function startup() {

   source /system/mount/mount.env
   rckill && run "${SCRIPT}"

}

function rcx() {

source /system/mount/mount.env

rclone mount remote: /mnt/unionfs \
--config=${CONFIG} --log-file=${MLOG} --log-level=${LOGLEVEL} \
--uid=${PUID} --gid=${PGID} --umask=${UMASK} \
--allow-other --allow-non-empty \
--timeout=1h --use-mmap \
--cache-dir=${TMPRCLONE} \
--tpslimit=${TPSLIMIT} --tpslimit-burst=${TPSBURST} \
--no-modtime --no-seek \
--drive-use-trash=${DRIVETRASH} \
--drive-stop-on-upload-limit \
--drive-server-side-across-configs \
--drive-acknowledge-abuse \
--ignore-errors --poll-interval=${POLL_INTERVAL} \
--user-agent=${UAGENT} --no-checksum \
--drive-chunk-size=${DRIVE_CHUNK_SIZE} \
--buffer-size=${BUFFER_SIZE} \
--dir-cache-time=${DIR_CACHE_TIME} \
--cache-info-age=${CACHE_INFO_AGE} \
--vfs-cache-poll-interval=${VFS_CACHE_POLL_INTERVAL} \
--vfs-cache-mode=${VFS_CACHE_MODE} \
--vfs-cache-max-age=${VFS_CACHE_MAX_AGE} \
--vfs-cache-max-size=${VFS_CACHE_MAX_SIZE} \
--vfs-read-chunk-size-limit=${VFS_READ_CHUNK_SIZE_LIMIT} \
--vfs-read-chunk-size=${VFS_READ_CHUNK_SIZE} \
--rc --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--rc-addr=localhost:${RC_ADDRESS}
}

function refreshVFS() {

   rclone rc vfs/refresh \
      recursive=true \
      --fast-list \
      --rc-user=${RC_USER} \
      --rc-pass=${RC_PASSWORD} \
      --config=${CONFIG} \
      --log-file=${RLLOG} \
      --log-level=${LOGLEVEL_RC}

}

function rckill() {

   rclone rc mount/unmount \
      mountPoint=${REMOTE} \
      --config=${CONFIG} \
      --rc-user=${RC_USER} \
      --rc-pass=${RC_PASSWORD} \
      --rc-addr=localhost:${RC_ADDRESS}

}

function rcdWAKEUP() {

   rclone rcd \
      --rc-user=${RC_USER} \
      --rc-pass=${RC_PASSWORD} \
      --rc-addr=localhost:${RC_ADDRESS} \
      --cache-dir=${TMPRCLONE}

}

function drivecheck() {

   if [ "$(ls -A /mnt/unionfs)" ] && [ "$(ps aux | grep -i 'rclone rc mount/mount' | grep -v grep)" != "" ]; then
      rclone rc fscache/clear \
         --fast-list \
         --rc-user=${RC_USER} \
         --rc-pass=${RC_PASSWORD} \
         --config=${CONFIG} \
         --log-file=${RLOG} \
         --log-level=${LOGLEVEL_RC}

      rclone rc vfs/refresh \
         recursive=true \
         --fast-list \
         --rc-user=${RC_USER} \
         --rc-pass=${RC_PASSWORD} \
         --config=${CONFIG} \
         --log-file=${RLOG} \
         --log-level=${LOGLEVEL_RC}
   fi

}

#########################################
# Till here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################
     ### DO NOT MAKE ANY CHANGES ###
### IF YOU DON'T KNOW WHAT YOU ARE DOING ###
