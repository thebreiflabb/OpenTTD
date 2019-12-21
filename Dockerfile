FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
	apt-get install -y --no-install-recommends \
	curl \
	vim \
	bzip2 \
	p7zip-full \
	ca-certificates \
	cmake \
	git \
	gnupg2 \
	libc6-dev \
	libfile-fcntllock-perl \
	libfontconfig-dev \
	libicu-dev \
	liblzma-dev \
	liblzo2-dev \
	libsdl1.2-dev \
	libsdl2-dev \
	libxdg-basedir-dev \
	make \
	software-properties-common \
	tar \
	wget \
	xz-utils \
	zlib1g-dev \
	default-jre \
	nodejs \
	python2.7 \
	g++ \
	binutils \
	gcc \
	file \
	&& rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

# emscripten install
WORKDIR /src/emsdk
RUN git clone https://github.com/emscripten-core/emsdk.git /src/emsdk
RUN ./emsdk install latest
RUN ./emsdk activate latest

# openttd
WORKDIR /src/openttd

COPY . ./

RUN echo 'Name: sdl2\n\
Description: Simple DirectMedia Layer is a cross-platform multimedia library designed to provide low level access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D video framebuffer.\n\
Version: 2.0.10\n' >> /src/emsdk/upstream/emscripten/system/lib/pkgconfig/sdl2.pc
RUN echo 'Name: zlib\n\
Description: zlib.\n\
Version: 1.2.8\n' >> /src/emsdk/upstream/emscripten/system/lib/pkgconfig/zlib.pc
RUN echo 'Name: lzma\n\
Description: lzma.\n\
Version: 5.2.4\n' >> /src/emsdk/upstream/emscripten/system/lib/pkgconfig/lzma.pc
RUN echo 'Name: liblzma\n\
Description: liblzma.\n\
Version: 5.2.4\n' >> /src/emsdk/upstream/emscripten/system/lib/pkgconfig/liblzma.pc

RUN /bin/bash -c 'source /src/emsdk/emsdk_env.sh && \
	echo running emconfigure && \
	emconfigure ./configure --static-icu --without-xdg-basedir --prefix-dir=/src/emsdk/upstream/emscripten/system --pkg-config="emconfigure pkg-config" && \
	echo done with emconfigure && \
	rm /src/emsdk/upstream/emscripten/system/lib/pkgconfig/sdl2.pc && \
	rm /src/emsdk/upstream/emscripten/system/lib/pkgconfig/zlib.pc && \
	rm /src/emsdk/upstream/emscripten/system/lib/pkgconfig/lzma.pc && \
	rm /src/emsdk/upstream/emscripten/system/lib/pkgconfig/liblzma.pc && \
	echo running emmake && \
	emmake make --jobs=2'
#RUN /bin/bash -c 'source /src/emsdk/emsdk_env.sh && emmake make --jobs=2'

ENTRYPOINT ["/bin/bash"]