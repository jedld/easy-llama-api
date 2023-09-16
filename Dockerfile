FROM ubuntu:22.04

# Run updates and install packages
RUN apt-get update && apt-get install -y \
    build-essential vim intel-opencl-icd clinfo ruby-full git libclblast-dev wget curl bzip2 cmake file python3 gcc g++ gfortran libopenblas-dev liblapack-dev pkg-config python3-pip python3-dev python3-venv \
    && wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list \
    && apt update && apt install -y intel-oneapi-mkl libjpeg-dev libpng-dev

WORKDIR /root/neo
COPY filelist-debs.txt .
RUN wget -i filelist-debs.txt \
    && dpkg -i *.deb

# Build level-zero
RUN git clone https://github.com/oneapi-src/level-zero.git \
    && mkdir -p level-zero/build && cd level-zero/build \
    && cmake .. \
    && cmake --build . --config Release --target package \
    && cmake --build . --config Release --target install

RUN git clone https://github.com/xianyi/OpenBLAS.git \
    && cd OpenBLAS \
    && make \
    && make install

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -q intel-oneapi-mkl intel-mkl libjpeg-dev libpng-dev libblas-dev libblas3 -y

# set intel one API env vars
# Set environment variables
ENV CMAKE_PREFIX_PATH="/opt/intel/oneapi/compiler/latest/linux/IntelDPCPP:/opt/intel/oneapi/tbb/latest/env/.." \
    CMPLR_ROOT="/opt/intel/oneapi/compiler/latest" \
    CPATH="/opt/intel/oneapi/tbb/latest/env/../include:/opt/intel/oneapi/mkl/latest/include:/usr/include/mkl" \
    DIAGUTIL_PATH="/opt/intel/oneapi/compiler/latest/sys_check/sys_check.sh" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:/opt/intel/oneapi/compiler/latest/linux/lib/x64:/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/tbb/latest/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/mkl/latest/lib/intel64:/usr/local/lib" \
    LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:/opt/intel/oneapi/compiler/latest/linux/lib:/opt/intel/oneapi/tbb/latest/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/mkl/latest/lib/intel64" \
    MANPATH="/opt/intel/oneapi/compiler/latest/documentation/en/man/common:" \
    MKLROOT="/opt/intel/oneapi/mkl/latest" \
    NLSPATH="/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin/locale/%l_%t/%N:/opt/intel/oneapi/mkl/latest/lib/intel64/locale/%l_%t/%N" \
    PATH="/opt/intel/oneapi/compiler/latest/linux/bin/intel64:/opt/intel/oneapi/compiler/latest/linux/bin:/opt/intel/oneapi/mkl/latest/bin/intel64:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    PKG_CONFIG_PATH="/opt/intel/oneapi/compiler/latest/lib/pkgconfig:/opt/intel/oneapi/tbb/latest/env/../lib/pkgconfig:/opt/intel/oneapi/mkl/latest/lib/pkgconfig" \
    TBBROOT="/opt/intel/oneapi/tbb/latest/env/.."

RUN gem install bundler
RUN bundle config build.llama_cpp --with-intel_mkl=yes
RUN mkdir /usr/app
COPY . /usr/app
WORKDIR /usr/app
RUN bundle
EXPOSE 3100
CMD ruby app.rb
