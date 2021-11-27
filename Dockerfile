# 前端开发中，时常需要使用 shell 命令，而有一个较为完整的环境比较重要，因此选择了使用 ubuntu 作为基础，若在意容器大小的话，可自行选择适用的基础镜像
FROM ubuntu:impish
MAINTAINER hsuhau "hsuhau@foxmail.com"

# 非交互式操作
ENV DEBIAN_FRONTEND noninteractive

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 暴露ssh端口
EXPOSE 22

# 设置root账号密码
RUN echo 'root:root' | chpasswd

# 用 root 用户操作
USER root

# 更换阿里云源，在国内可以加快速度
RUN sed -i "s/security.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/security-cdn.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list

# 更新源，安装相应工具
RUN apt update && apt install -y \
    zsh \
    vim \
    wget \
    curl \
    nano \
    git \
    python3 \
    golang \
    openjdk-8-jdk \
    maven \
    gradle \
    openssh-server \
    nodejs \
    npm \
    gcc \
    gdb \
    cmake

# 为 root 安装 oh-my-zsh
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && chsh -s /bin/zsh

# ssh配置
COPY config/* /tmp/
RUN cat /tmp/sshd_config >> /etc/ssh/sshd_config
RUN mkdir ~/.ssh
RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa
RUN /etc/init.d/ssh restart

# 配置 Java 8 环境变量
RUN echo '' >> ~/.zshrc \
    && echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.zshrc \
    && echo 'export JRE_HOME=${JAVA_HOME}/jre' >> ~/.zshrc \
    && echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> ~/.zshrc \
    && echo 'export PATH=.:${JAVA_HOME}/bin:$PATH' >> ~/.zshrc

# 配置 Maven 环境变量
RUN echo '' >> ~/.zshrc \
    && echo 'export M2_HOME=/usr/share/maven' >> ~/.zshrc \
    && echo 'export PATH=${M2_HOME}/bin:${PATH}' >> ~/.zshrc
            
# 配置 Gradle 环境变量
RUN echo '' >> ~/.zshrc \
    && echo 'export GRADLE_HOME=/usr/share/gradle' >> ~/.zshrc \
    && echo 'export PATH=${GRADLE_HOME}/bin:${PATH}' >> ~/.zshrc

# 配置 GOPROXY 环境变量
RUN echo '' >> ~/.zshrc \
    && echo 'export GOPROXY=https://goproxy.io,direct' >> ~/.zshrc

# 删除 apt/lists，可以减少最终镜像大小，详情见：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#general-guidelines-and-recommendations
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /GitHub
