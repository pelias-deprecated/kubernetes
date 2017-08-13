# base image
FROM ubuntu:latest

# configure env
ENV DEBIAN_FRONTEND 'noninteractive'

# update apt, install core apt dependencies and delete the apt-cache
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && \
    apt-get install -y locales iputils-ping curl wget git-core htop python-pip vim unzip && \
    rm -rf /var/lib/apt/lists/*


# install AWS CLI
RUN pip install awscli

# everything should be installed under the root user's home directory
WORKDIR /root

# set up local bin directory
RUN mkdir -p ~/.local/bin

# download kubectrl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod u+x kubectl && mv kubectl ~/.local/bin

# download kops
RUN wget https://github.com/kubernetes/kops/releases/download/1.7.0/kops-linux-amd64 && chmod u+x kops-linux-amd64 && mv kops-linux-amd64 ~/.local/bin/kops

# download packer
RUN wget https://releases.hashicorp.com/packer/1.0.4/packer_1.0.4_linux_amd64.zip && \
    unzip packer_1.0.4_linux_amd64.zip && chmod u+x packer && \
	mv packer ~/.local/bin/ && rm packer_1.0.4_linux_amd64.zip

# download terraform
RUN wget https://releases.hashicorp.com/terraform/0.10.0/terraform_0.10.0_linux_amd64.zip && \
    unzip terraform_0.10.0_linux_amd64.zip && chmod u+x terraform && \
	mv terraform ~/.local/bin/ && rm terraform_0.10.0_linux_amd64.zip

# include local bin directory in path
RUN echo "export PATH=\"\$HOME/.local/bin:\$PATH\"">> .bashrc

CMD ["/bin/bash"]
