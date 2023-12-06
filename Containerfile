FROM quay.io/centos-bootc/centos-bootc-dev:stream9
RUN rpm-ostree install gdm firefox gnome-kiosk-script-session plymouth-system-theme firewalld
RUN rm -rf /var/lib/gdm/.config/pulse/default.pa && rm -rf /var/lib/xkb/README.compiled
COPY custom.conf /etc/gdm/
COPY core.conf /usr/lib/sysusers.d/
COPY --chmod=0755 --chown=1042:1042 gnome-kiosk-script /usr/lib/
COPY kiosk-gdm /usr/lib/
COPY kiosk.conf /usr/lib/tmpfiles.d/
RUN mkdir -p /usr/etc-system/ && \
    echo 'AuthorizedKeysFile /usr/etc-system/%u.keys' >> /etc/ssh/sshd_config.d/30-auth-system.conf && \
    echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7xFq1HtZKZiaD8MfkhNtn37m8GSc1W168NoSaT9RSf cardno:000F_C36A3FC0' > /usr/etc-system/root.keys && chmod 0600 /usr/etc-system/root.keys
RUN systemctl enable sshd && firewall-offline-cmd --disabled
RUN systemctl set-default graphical.target && ostree container commit
