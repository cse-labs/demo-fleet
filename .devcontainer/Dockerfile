# this image is built and updated weekly
# https://github.com/cse-labs/codespaces-images

FROM ghcr.io/cse-labs/k3d:latest

# some images require specific values
ARG USERNAME=vscode

# install gh; update welcome message; chown home dir
RUN echo "$(date +'%Y-%m-%d %H:%M:%S')    docker build start" >> "/home/${USERNAME}/status" && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
    apt-add-repository https://cli.github.com/packages && \
    apt update && \
    apt install gh && \
    echo "👋 Welcome to Pilot-in-a-Box!" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt && \
    echo "" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt && \
    echo "🔍 To explore PiB, open the README.md file" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt && \
    echo "" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt && \
    sed -i "s|((sleep 10s; touch |# ((sleep 10s; touch |g" /etc/bash.bashrc && \
    sed -i "s|((sleep 10s; touch |# ((sleep 10s; touch |g" /etc/zsh/zshrc && \
    chown -R ${USERNAME}:${USERNAME} "/home/${USERNAME}" && \
    echo "$(date +'%Y-%m-%d %H:%M:%S')    docker build complete" >> "/home/${USERNAME}/status"
