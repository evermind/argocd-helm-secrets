FROM argoproj/argocd:v2.0.3

ARG HELM_SECRETS_VERSION=v3.8.1

# Switch to root user to perform installation
USER root  
# COPY helm-wrapper.sh /usr/local/bin/
RUN apt-get update && \
    apt-get install -y \
    curl \
    nano
    # gpg && \
    # apt-get clean && \
    # rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    # chmod +x /usr/local/bin/sops && \
    # cd /usr/local/bin && \
    # mv helm helm.bin && \
    # mv helm2 helm2.bin && \
    # mv helm-wrapper.sh helm && \
    # ln helm helm2 && \
    # chmod +x helm helm2

RUN helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION}

USER argocd
