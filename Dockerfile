# jackett and OpenVPN
#
# Version 1.8

FROM ubuntu:18.04
LABEL maintainer="JanVanBraeckel"

VOLUME /config

ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
    XDG_CONFIG_HOME="/config"

RUN usermod -u 99 nobody

# Update packages and install software
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils openssl \
    && apt-get install -y software-properties-common curl jq \

    && mkdir -p /app/Jackett \
    && if [ -z ${JACKETT_RELEASE+x} ]; then \
    JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
    | jq -r .tag_name); \
    fi  \
    && curl -o /tmp/jacket.tar.gz -L \
    "https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.LinuxAMDx64.tar.gz" \
    && tar xf \
    /tmp/jacket.tar.gz -C \
    /app/Jackett --strip-components=1 \
    && echo "**** fix for host id mapping error ****" \
    && chown -R root:root /app/Jackett \

    && apt-get update \
    && apt-get install -y openvpn moreutils net-tools dos2unix kmod iptables ipcalc unrar \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration and scripts
ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh

# Expose ports and run
EXPOSE 9117
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
