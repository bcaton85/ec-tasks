FROM registry.access.redhat.com/ubi8/ubi

ARG POLICY_REPO
ARG POLICY_COMMIT

COPY kubernetes.repo /tmp/kubernetes.repo

RUN cat /tmp/kubernetes.repo | tee /etc/yum.repos.d/kubernetes.repo && \
    dnf install --setopt=tsflags=nodocs -y kubectl git jq https://github.com/tektoncd/cli/releases/download/v0.22.0/tektoncd-cli-0.22.0_Linux-64bit.rpm && \
    dnf clean all
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.15.1/yq_linux_amd64 -o /usr/bin/yq && chmod +x /usr/bin/yq
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.9/openshift-client-linux.tar.gz | tar -xz -C /usr/bin/
RUN curl -L https://github.com/sigstore/cosign/releases/download/v1.7.1/cosign-linux-amd64 -o /usr/bin/cosign && chmod +x /usr/bin/cosign
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/0.21.0/tkn-linux-amd64-0.21.0.tar.gz | tar -xz --no-same-owner -C /usr/bin/
RUN curl -L https://github.com/sigstore/rekor/releases/download/v0.5.0/rekor-cli-linux-amd64 -o /usr/bin/rekor-cli && chmod +x /usr/bin/rekor-cli
RUN curl -L https://github.com/open-policy-agent/opa/releases/download/v0.38.0/opa_linux_amd64 -o /usr/bin/opa && chmod +x /usr/bin/opa

WORKDIR /home/enterprise-contract

# TODO: Cloning the Git repo - use a Git submodule instead?
RUN git clone $POLICY_REPO && cd ec-policies && git checkout $POLICY_COMMIT
