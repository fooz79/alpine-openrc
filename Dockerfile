FROM alpine:3.13

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update --no-cache \
    && apk upgrade --no-cache \
    && apk add --no-cache openrc bash tzdata \
    # Disable getty's
    && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
    # Change rc.conf
    && sed -i \
    # Change subsystem type to "docker"
    -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
    # Allow all variables through
    -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
    # Start crashed services
    -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
    -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
    # Define extra dependencies for services
    -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
    /etc/rc.conf \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
    /etc/init.d/hwclock \
    /etc/init.d/hwdrivers \
    /etc/init.d/modules \
    /etc/init.d/modules-load \
    /etc/init.d/modloop \
    /etc/init.d/machine-id \
    # Don't do cgroups
    && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
    # timezone
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    # && apk del tzdata \
    # modify bashrc
    && echo "PS1='\033[1;33m\h \033[1;34m[\w] \033[1;35m\D{%D %T}\n\[\033[1;36m\]\u@\l \[\033[00m\]\$ '" > /root/.bashrc \
    && echo "alias ll='ls -l'" >> /root/.bashrc

CMD ["/sbin/init"]
