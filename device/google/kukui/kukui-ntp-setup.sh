#!/system/bin/sh
# Pick the NTP server by system language and force an early network-time sync.
#
# The device has no RTC: the clock boots at the image build time and every
# TLS-dependent app misbehaves until NTP lands.
#
# Language rule: Simplified Chinese systems use domestic (GFW-reachable)
# servers; every other language keeps the framework default
# (time.android.com). Multiple servers are pipe-separated; the SNTP client
# walks the list.
#
# Private DNS is pinned to an encrypted resolver: the LAN router's DNS
# answered NTP hostnames in a way that left the SNTP UDP queries unanswered
# (the clock stalled for weeks). DoT reaches a real resolver over TCP, which
# works on that same network.

LOG_TAG=kukui-ntp

wait_for_wan() {
    # ICMP to a fixed public IP: no DNS involved, proves the default route.
    i=0
    while [ "$i" -lt 60 ]; do
        if ping -c1 -W2 223.5.5.5 >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
        i=$((i + 1))
    done
    return 1
}

set -x

wait_for_wan || log -t "$LOG_TAG" "WAN not reachable in 120s; NTP will retry on its own"

LOCALE="$(getprop persist.sys.locale)"
case "$LOCALE" in
    zh-CN*|zh-Hans*|zh_SG*)
        log -t "$LOG_TAG" "locale $LOCALE -> domestic NTP"
        settings put global ntp_server "ntp.aliyun.com|ntp.tencent.com|cn.pool.ntp.org"
        ;;
    *)
        log -t "$LOG_TAG" "locale $LOCALE -> default NTP"
        settings put global ntp_server ""
        ;;
esac

settings put global private_dns_mode hostname
settings put global private_dns_specifier dns.alidns.com

# Nudge the time detector: toggling auto_time restarts the network time
# strategy, firing an immediate SNTP query instead of waiting for the next
# poll interval.
settings put global auto_time 0
sleep 1
settings put global auto_time 1
log -t "$LOG_TAG" "ntp setup done"
