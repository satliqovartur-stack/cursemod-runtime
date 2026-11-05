#!/system/bin/sh
set -u
cd /data/local/tmp/cursemod-v3 || exit 1
umask 077
owned_pid() {
  [ -f run.pid ] || return 1
  p="$(cat run.pid)"
  case "$p" in ''|*[!0-9]*) return 1;; esac
  [ "$(readlink /proc/$p/exe 2>/dev/null)" = "$PWD/cursemod" ] || return 1
  echo "$p"
}
case "${1:-start}" in
 status) p="$(owned_pid)" || exit 0; kill -0 "$p" 2>/dev/null || exit 0; cat state.json 2>/dev/null; exit 0;;
 show) p="$(owned_pid)" || exit 1; kill -USR2 "$p"; exit $?;;
 toggle) p="$(owned_pid)" || exit 1; kill -USR1 "$p"; exit $?;;
 stop) p="$(owned_pid)" || exit 0; kill -TERM "$p"; for n in 1 2 3 4 5 6 7 8 9 10; do owned_pid >/dev/null || exit 0; sleep 1; done; exit 1;;
 start|preview|dump) ;;
 *) exit 2;;
esac
if p="$(owned_pid)"; then kill -USR2 "$p"; echo "$p"; exit 0; fi
rm -f state.json state.json.tmp
export OXESP_MENU=1
if [ "${1:-start}" = preview ]; then export CURSEMOD_PREVIEW=1; export OX_SAFE=1; fi
if [ "${1:-start}" = dump ]; then export OX_SAFE=1; export CURSEMOD_DUMP=1; fi
trap '' HUP
nohup setsid ./cursemod > session.log 2>&1 < /dev/null &
echo "$!" > run.pid
echo "$!"
n=0
while [ "$n" -lt 150 ]; do
  n=$((n + 1))
  if p="$(owned_pid)" && [ -s state.json ]; then exit 0; fi
  sleep 0.1
done
tail -n 12 session.log >&2
exit 1
