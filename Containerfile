FROM quay.io/centos-boot/centos-tier-1-dev:stream9
RUN rpm-ostree install gdm firefox gnome-kiosk-script-session plymouth-system-theme
RUN rm -rf /var/lib/gdm/.config/pulse/default.pa && rm -rf /var/lib/xkb/README.compiled
COPY custom.conf /etc/gdm/
COPY core.conf /usr/lib/sysusers.d/
COPY gnome-kiosk-script /usr/lib/
COPY kiosk-gdm /usr/lib/
COPY kiosk.conf /usr/lib/tmpfiles.d/
RUN systemctl set-default graphical.target && ostree container commit
