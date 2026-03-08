FROM ubuntu:misc

# Flutter
ARG flutter_version=3.38.10
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    pkg-config \
    libgtk-3-dev \
    openjdk-17-jdk \
    mesa-utils 

# Clone Flutter
RUN git clone -b ${flutter_version} --depth 1 https://github.com/flutter/flutter.git /usr/local/flutter
RUN chown -R $(whoami):$(whoami) /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:${PATH}"

RUN flutter precache

RUN dart --disable-analytics
RUN flutter config --no-analytics

ARG sdk_version=14742923
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk-${sdk_version}
ENV PATH="$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/temp && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${sdk_version}_latest.zip -O /tmp/tools.zip && \
    unzip -q /tmp/tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools/temp && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/temp/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm -rf /tmp/tools.zip ${ANDROID_SDK_ROOT}/cmdline-tools/temp


RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

RUN flutter config --android-sdk ${ANDROID_SDK_ROOT}
RUN flutter doctor --android-licenses
