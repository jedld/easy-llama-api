FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install build-essential intel-opencl-icd clinfo ruby-full git libclblast-dev wget -y
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \ | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list
RUN apt update
RUN apt install intel-oneapi-mkl -y
RUN gem install bundler
RUN bundle config build.llama_cpp --with-clblast=yes
RUN mkdir /usr/app
COPY . /usr/app
WORKDIR /usr/app
RUN bundle
EXPOSE 3100
CMD ruby app.rb